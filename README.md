# MLB-Pitching-Analyzer

A web-based MLB Pitching Analyzer built with Python and the Bottle framework, featuring an HTML/CSS/JavaScript frontend with Bootstrap, that looks at all MLB pitching data from 1890 - 2017 and provides visualizations and interactions for various statistics.

## Features

- All MLB pitching data up until 2017
- Interactive charts and tables
- Supports SQLite for local database storage
- Simple, lightweight web interface using Bottle templates (`.tpl` files)

## Tech Stack

- **Python 3.13**
- **Bottle** - lightweight Python web framework
- **SQLite** - or local data storage (originally was PostGreSQL, but transitioned to SQLite to commit entire project to GitHub)
- **Bootstrap**
- **HTML/CSS/JavaScript**
- HTML templates in `views/` using Bottle's SimpleTemplate

## Project Structure

```text
MLB-Pitching-Analyzer/
├── gui/
│   ├── hello_bottle.py # Main Bottle app
│   ├── views/          # HTML templates (.tpl)
│   └── data/           # SQLite database files
├── requirements.txt  # Python dependencies
└── README.md         # Project documentation
```

> ⚠️ **Note:** Launch the app using `hello_bottle.py` from the `gui/` folder so paths to templates and the database resolve correctly.

## Imports

```python
from psychopg import connect
from bottle import Bottle, template, static_file, request, SimpleTemplate
import json
import csv
import sqlite3
```

## Installation

1. Clone the Repository

```bash
git clone <repo-url>
cd MLB-Pitching-Analyzer
```

2. Install dependencies

```bash
pip install -r requirements.txt
```

## Usage

1. Navigate to `gui/` folder

```bash
cd gui
```

2. Run the Bottle app

```bash
python hello_bottle.py
```

3. Open browser and navigate to

```cpp
http://127.0.0.1:8080/
```
