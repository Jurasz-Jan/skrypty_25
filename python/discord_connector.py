import os
import aiohttp
import discord
import asyncio

RASA_URL = "http://127.0.0.1:5005/webhooks/rest/webhook"

intents = discord.Intents.default()
intents.message_content = True  # <-- KLUCZOWE
client = discord.Client(intents=intents)

token = os.getenv("DISCORD_TOKEN")

@client.event
async def on_ready():
    print(f"Logged in as {client.user}")

@client.event
async def on_message(message):
    if message.author == client.user:
        return

    payload = {"sender": str(message.author.id), "message": message.content}
    try:
        async with aiohttp.ClientSession() as session:
            async with session.post(RASA_URL, json=payload) as resp:
                if resp.status == 200:
                    data = await resp.json()
                    for r in data:
                        if "text" in r:
                            await message.channel.send(r["text"])
                else:
                    await message.channel.send(f"Error: HTTP {resp.status}")
    except Exception as e:
        await message.channel.send(f"Error: {e}")

if __name__ == "__main__":
    if not token:
        raise RuntimeError("Please set the DISCORD_TOKEN environment variable")
    client.run(token)
