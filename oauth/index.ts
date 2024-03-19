import Elysia from "elysia";

const app = new Elysia()
  .get("/twitch/oauth", async (ctx) => {
    console.log(JSON.stringify(ctx.query));
  })
  .listen(3030);

console.log(
  `🦊 Elysia is running at ${app.server?.hostname}:${app.server?.port}`,
);

const url = ` 
https://id.twitch.tv/oauth2/authorize
    ?response_type=code
    &client_id=cew8p1bv247ua1czt6a1okon8ejy1r
    &redirect_uri=http://localhost:3030/twitch/oauth
    &scope=user%3Awrite%3Achat+user%3Abot+channel%3Abot
    &state=foobar
`;
