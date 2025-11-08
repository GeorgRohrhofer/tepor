from flask import Flask, jsonify, request, render_template
from flask_cors import CORS
import discordBot as dbot
from threading import Thread
import os
import asyncio

app = Flask(__name__)
CORS(app)

def start_api():
    app.run(host="0.0.0.0", port=6969)

@app.post("/message/send/channel")
def messageSendToChannels():
   
    jdata = request.get_json()    
    future = asyncio.run_coroutine_threadsafe(
        dbot.send_to_all_channels(jdata["channels"], jdata["messageContent"]),
        dbot.client.loop
    )
    future.result(timeout=10)
    
    return "Success", 200

@app.post("/message/send/direct")
def messageSendToDirects():
   
    jdata = request.get_json()    
    future = asyncio.run_coroutine_threadsafe(
        dbot.send_to_all_directs(jdata["directs"], jdata["messageContent"]),
        dbot.client.loop
    )
    future.result(timeout=10)
    
    return "Success", 200


if __name__ == "__main__":
    flask_thread = Thread(target=start_api)
    flask_thread.daemon=True
    flask_thread.start()
    dbot.start_bot(os.getenv("DISCORD_BOT_TOKEN"))
    