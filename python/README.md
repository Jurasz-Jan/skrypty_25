# Rasa Restaurant Chatbot

This directory contains an example Rasa project that implements a simple restaurant chatbot. The bot supports:

- Showing opening hours (loaded from `actions/hours.txt`).
- Displaying the menu (`actions/menu.txt`).
- Taking an order and summarizing it including a delivery address using a form.

It contains at least three conversation stories and can be integrated with Discord using `discord_connector.py`.

## Usage

1. Install dependencies (Rasa):
   ```bash
   pip install rasa
   ```
2. Train the model:
   ```bash
   rasa train
   ```
3. Run the action server and the bot in separate terminals:
   ```bash
   rasa run actions
   rasa run -m models --endpoints endpoints.yml --credentials credentials.yml
   ```

Install `discord.py` and set the `DISCORD_TOKEN` environment variable. Then run:
```bash
python discord_connector.py
```
to connect the bot with Discord.
