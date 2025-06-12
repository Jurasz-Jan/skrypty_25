import os
import requests
import discord

RASA_URL = "http://localhost:5005/webhooks/rest/webhook"

intents = discord.Intents.default()
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
        response = requests.post(RASA_URL, json=payload)
        for r in response.json():
            if "text" in r:
                await message.channel.send(r["text"])
    except Exception as e:
        await message.channel.send(f"Error: {e}")

if __name__ == "__main__":
    if not token:
        raise RuntimeError("Please set the DISCORD_TOKEN environment variable")
    client.run(token)
