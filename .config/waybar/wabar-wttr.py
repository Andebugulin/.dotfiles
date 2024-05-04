#!/usr/bin/env python

import json
import requests
from datetime import datetime

WEATHER_CODES = {
    '113': '☀️',
    '116': '⛅️',
    '119': '☁️',
    '122': '☁️',
    '143': '🌫',
    '176': '🌦',
    '179': '🌧',
    '182': '🌧',
    '185': '🌧',
    '200': '⛈',
    '227': '🌨',
    '230': '❄️',
    '248': '🌫',
    '260': '🌫',
    '263': '🌦',
    '266': '🌦',
    '281': '🌧',
    '284': '🌧',
    '293': '🌦',
    '296': '🌦',
    '299': '🌧',
    '302': '🌧',
    '305': '🌧',
    '308': '🌧',
    '311': '🌧',
    '314': '🌧',
    '317': '🌧',
    '320': '🌨',
    '323': '🌨',
    '326': '🌨',
    '329': '❄️',
    '332': '❄️',
    '335': '❄️',
    '338': '❄️',
    '350': '🌧',
    '353': '🌦',
    '356': '🌧',
    '359': '🌧',
    '362': '🌧',
    '365': '🌧',
    '368': '🌨',
    '371': '❄️',
    '374': '🌧',
    '377': '🌧',
    '386': '⛈',
    '389': '🌩',
    '392': '⛈',
    '395': '❄️'
}

data = {}


weather = requests.get("https://wttr.in/?format=j1").json()


def format_time(time):
    return time.replace("00", "").zfill(2)


def format_temp(temp):
    return (hour['FeelsLikeC']+"°").ljust(3)


def format_chances(hour):
    chances = {
        "chanceoffog": "Fog",
        "chanceoffrost": "Frost",
        "chanceofovercast": "Overcast",
        "chanceofrain": "Rain",
        "chanceofsnow": "Snow",
        "chanceofsunshine": "Sunshine",
        "chanceofthunder": "Thunder",
        "chanceofwindy": "Wind"
    }

    conditions = []
    for event in chances.keys():
        if int(hour[event]) > 0:
            conditions.append(chances[event]+" "+hour[event]+"%")
    return ", ".join(conditions)


data['text'] = WEATHER_CODES[weather['current_condition'][0]['weatherCode']] + \
    " "+weather['current_condition'][0]['FeelsLikeC']+"°"

data['tooltip'] = f"<b>{weather['current_condition'][0]['weatherDesc'][0]['value']} {weather['current_condition'][0]['temp_C']}°</b>\n"
data['tooltip'] += f"Feels like: {weather['current_condition'][0]['FeelsLikeC']}°\n"
data['tooltip'] += f"Wind: {weather['current_condition'][0]['windspeedKmph']}Km/h\n"
data['tooltip'] += f"Humidity: {weather['current_condition'][0]['humidity']}%\n"
for i, day in enumerate(weather['weather']):
    data['tooltip'] += f"\n<b>"
    if i == 0:
        data['tooltip'] += "Today, "
    if i == 1:
        data['tooltip'] += "Tomorrow, "
    data['tooltip'] += f"{day['date']}</b>\n"
    data['tooltip'] += f"⬆️ {day['maxtempC']}° ⬇️ {day['mintempC']}° "
    data['tooltip'] += f"🌅 {day['astronomy'][0]['sunrise']} 🌇 {day['astronomy'][0]['sunset']}\n"
    for hour in day['hourly']:
        if i == 0:
            if int(format_time(hour['time'])) < datetime.now().hour-2:
                continue
        data['tooltip'] += f"{format_time(hour['time'])} {WEATHER_CODES[hour['weatherCode']]} {format_temp(hour['FeelsLikeC'])} {hour['weatherDesc'][0]['value']}, {format_chances(hour)}\n"

def create_fully_aligned_terminal_look(weather_data):
    # Box drawing characters
    horizontal_line = '─'
    vertical_line = '│'
    top_left_corner = '┌'
    top_right_corner = '┐'
    bottom_left_corner = '└'
    bottom_right_corner = '┘'
    connector_left = '├'
    connector_right = '┤'

    # Dynamic title and subtitle
    subtitle = f"{WEATHER_CODES[weather_data['current_condition'][0]['weatherCode']]} {weather_data['current_condition'][0]['weatherDesc'][0]['value']} {weather_data['current_condition'][0]['temp_C']}°C"

    # Preparing content lines
    content_lines = [
        f"{day['date']}: High {day['maxtempC']}°C, Low {day['mintempC']}°C, Sunrise: {day['astronomy'][0]['sunrise']}, Sunset: {day['astronomy'][0]['sunset']}"
        for day in weather_data['weather']
    ]

    # Finding the max content width
    max_content_width = max( len(subtitle), max(len(line) for line in content_lines))

    # Adjust box width for the borders
    box_width = max_content_width + 4  # 2 spaces padding on each side

    # Top part of the box
    box_top = f"{top_left_corner}{horizontal_line * (box_width-2)}{top_right_corner}\n"
    # Title and subtitle, centered with padding
    subtitle_line = f"{vertical_line} {subtitle}\n"                                            
    connector = f"{connector_left}{horizontal_line * (box_width-2)}{connector_right}\n"

    # Adding content lines, ensuring they're centered
    content_str = ""
    for line in content_lines:
        # Center each line within the box, accounting for border space
        content_str += f"{vertical_line} {line}\n"
        

    # Bottom part of the box
    box_bottom = f"{bottom_left_corner}{horizontal_line * (box_width-2)}{bottom_right_corner}\n"

    # Combine all parts
    full_box = box_top + subtitle_line + connector + content_str + box_bottom
    return full_box
# Apply the updated function for a neat and aligned display
data['tooltip'] = create_fully_aligned_terminal_look(weather)
print(json.dumps(data))
