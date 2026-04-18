import { serve } from "https://deno.land/std/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { readAll } from "https://deno.land/std@0.224.0/streams/conversion.ts";
import { encode } from "https://deno.land/std@0.224.0/encoding/base64.ts";

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  const payload = await req.json();
  const { chat_id, sender_id, content } = payload;

  // znajdź uczestników czatu
  const { data: participants } = await supabase
    .from("chat_participants")
    .select("user_id")
    .eq("chat_id", chat_id);

  if (!participants) return new Response("no participants", { status: 200 });

  const receiverIds = participants.map((p: any) => p.user_id).filter((id: string) => id !== sender_id);

  if (receiverIds.length === 0) return new Response("no receivers", { status: 200 });

  // tokeny odbiorców
  const { data: devices } = await supabase
    .from("user_devices")
    .select("token")
    .in("user_id", receiverIds);

  if (!devices || devices.length === 0) return new Response("no device tokens", { status: 200 });

  const tokens = devices.map((d: any) => d.token);

  // FCM HTTP v1
  const serviceAccount = JSON.parse(Deno.env.get("FCM_SERVICE_ACCOUNT")!);

  // Generate OAuth2 token
  const jwtHeader = { alg: "RS256", typ: "JWT" };
  const iat = Math.floor(Date.now() / 1000);
  const exp = iat + 3600; // 1h

  const claimSet = {
    iss: serviceAccount.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat,
    exp,
  };

  function base64urlEncode(obj: any) {
    return btoa(JSON.stringify(obj))
      .replace(/=/g, "")
      .replace(/\+/g, "-")
      .replace(/\//g, "_");
  }

  const unsignedJWT = `${base64urlEncode(jwtHeader)}.${base64urlEncode(claimSet)}`;

  // podpisz JWT przy pomocy klucza prywatnego
  // Deno nie ma wbudowanego RS256, więc najlepiej użyć pakietu np. jose
  // lub skorzystać z gotowego tokena OAuth generowanego w backendzie

  // Tu dla uproszczenia zakładam, że masz już token:
  const accessToken = "<GENERATED_ACCESS_TOKEN>"; // generuj na backendzie

  // wysyłka powiadomień
  for (const token of tokens) {
    await fetch(`https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: {
          token,
          notification: {
            title: "Nowa wiadomość",
            body: content,
          },
          data: {
            chat_id: String(chat_id),
          },
        },
      }),
    });
  }

  return new Response(JSON.stringify({ ok: true }), { status: 200 });
});
