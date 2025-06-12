from typing import Any, Text, Dict, List
import os
from rasa_sdk import Action, Tracker
from rasa_sdk.executor import CollectingDispatcher


class ActionShowHours(Action):
    def name(self) -> Text:
        return "action_show_hours"

    def run(
        self,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: Dict[Text, Any],
    ) -> List[Dict[Text, Any]]:
        hours_file = os.path.join(os.path.dirname(__file__), "hours.txt")
        with open(hours_file, "r", encoding="utf-8") as f:
            hours = f.read()
        dispatcher.utter_message(text=f"Our opening hours:\n{hours}")
        return []


class ActionShowMenu(Action):
    def name(self) -> Text:
        return "action_show_menu"

    def run(
        self,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: Dict[Text, Any],
    ) -> List[Dict[Text, Any]]:
        menu_file = os.path.join(os.path.dirname(__file__), "menu.txt")
        with open(menu_file, "r", encoding="utf-8") as f:
            menu = f.read()
        dispatcher.utter_message(text=f"Today's menu:\n{menu}")
        return []


class ActionSubmitOrder(Action):
    def name(self) -> Text:
        return "action_submit_order"

    def run(
        self,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: Dict[Text, Any],
    ) -> List[Dict[Text, Any]]:
        item = tracker.get_slot("item")
        quantity = tracker.get_slot("quantity")
        address = tracker.get_slot("address")

        summary = f"You ordered {quantity} x {item}. "
        if address:
            summary += f"Delivery address: {address}."
        dispatcher.utter_message(text=summary)
        return []
