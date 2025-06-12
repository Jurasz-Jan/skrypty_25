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
        # This path assumes hours.txt is in the same directory as actions.py
        # If your actions.py is in 'actions/' and hours.txt is in the project root,
        # you might need: os.path.join(os.path.dirname(__file__), '..', 'hours.txt')
        # For simplicity, if actions.py and hours.txt are in the same place:
        hours_file = "hours.txt"

        try:
            with open(hours_file, "r", encoding="utf-8") as f:
                hours = f.read()
            dispatcher.utter_message(text=f"Our opening hours:\n{hours}")
        except FileNotFoundError:
            dispatcher.utter_message(text="Przepraszam, nie mogę znaleźć informacji o godzinach otwarcia.")
        except Exception as e:
            dispatcher.utter_message(text=f"Wystąpił błąd podczas odczytu godzin otwarcia: {e}")
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
        # Similar path consideration as above
        menu_file = "menu.txt"

        try:
            with open(menu_file, "r", encoding="utf-8") as f:
                menu = f.read()
            dispatcher.utter_message(text=f"Today's menu:\n{menu}")
        except FileNotFoundError:
            dispatcher.utter_message(text="Przepraszam, nie mogę znaleźć menu.")
        except Exception as e:
            dispatcher.utter_message(text=f"Wystąpił błąd podczas odczytu menu: {e}")
        return []

# ActionSubmitOrder removed as ordering functionality is deleted.