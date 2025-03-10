# NY-9AM-BreakFakeOut-Bot 

NY-9AM-Breakout-Bot is an advanced MQL5 trading bot designed to execute a breakout strategy on a 4-hour timeframe. By default, it uses New York time (9 AM) for trade execution, making it ideal for capturing opportunities that often coincide with key market news releases. The bot is highly effective when used alongside news trading strategies, and it adjusts dynamically for time zone differences and DST changes.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Configuration and Inputs](#configuration-and-inputs)
- [How It Works](#how-it-works)
- [Files Structure](#files-structure)
- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

NY-9AM-Breakout-Bot is a fully automated breakout trading bot built with MQL5. It analyzes the high and low of a 4-hour candle and places limit orders based on these key levels. When the market price reaches a defined level (e.g., the candle low), the bot cancels the opposite order accordingly. With dynamic time adjustments—including support for Daylight Saving Time (DST)—and integrated risk management features, this bot helps traders execute a precise and balanced breakout strategy.

---

## Features

- **Breakout Strategy:**  
  - Uses the high and low of a 4-hour candle to set limit orders.
  - **Take Profit:** Set at half the candle size (difference between high and low).
  - **Stop Loss:** Set equal to the candle size, ensuring a clear risk/reward ratio.
  
- **Dynamic Time Zone & DST Adjustments:**  
  - Accepts user-defined UTC offsets for DST-active and non-DST periods.
  - Adjusts automatically based on user-provided DST start and end dates.
  - By default, trades are evaluated at New York 9 AM.
  
- **Multiple Entry Times:**  
  - Supports up to three distinct trade entry times per day (e.g., 1, 5, and 9 o’clock) for flexible market entry.
  
- **Broker Server Time Zone Handling:**  
  - Configurable settings ensure the bot's internal clock is in sync with the broker’s trading hours.
  
- **Risk Management:**  
  - **Trade Risk:** Define the percentage of the account balance risked on each trade.
  - **Monthly Profit Target and Loss Limit:**  
    The bot monitors monthly performance and stops trading for the month if the profit target or loss limit is reached, resuming only at the start of a new month.
  
- **News Integration:**  
  - The bot’s timing and strategy are well-suited for trading around key news releases.
  
- **Cross-Platform Considerations:**  
  - **Wine Requirement:**  
    If you are running MetaTrader 5 on Linux, Wine is required to support the Windows-based MT5 installation.
  
- **File Deployment Scripts:**  
  - Bash scripts are provided to automatically copy the necessary `.mqh` and `.mq5` files to your MT5 directories.

---

## Configuration and Inputs

The bot is configured via several input parameters defined in the MQL5 files. Below is a detailed explanation of each group:

### 1. Desired Time Zone Settings
- **UTCOffsetDst (e.g., GMT_Minus_4):**  
  The UTC offset when Daylight Saving Time (DST) is active. Used for adjusting the bot’s trading times during DST.
  
- **UTCOffsetNonDst (e.g., GMT_Minus_5):**  
  The UTC offset during standard (non-DST) periods.
  
- **DSTStartMonth & DSTStartDay:**  
  The month and day when DST begins (e.g., March 9th).
  
- **DSTEndMonth & DSTEndDay:**  
  The month and day when DST ends (e.g., November 2nd).

### 2. Entring Time
- **Initial_Time, Second_Time, Third_Time:**  
  Define three distinct trade entry times (e.g., 1, 5, and 9 o’clock). The bot will check for favorable market conditions at these times.  
  *By default, trades are set to be evaluated at New York 9 AM.*

### 3. Server Time Zone
- **UTCServerDst & UTCServerNonDst:**  
  These settings correspond to the broker’s server time zone during DST and non-DST periods, ensuring the bot's internal clock is in sync with market operations.

### 4. Risk Management in % of the Balance
- **TradeRisk:**  
  The percentage of the account balance risked on each trade.
  
- **MonthTarget:**  
  The monthly profit target expressed as a percentage of the initial monthly balance. Once reached, the bot will stop trading for the rest of that month.
  
- **MonthLost:**  
  The monthly loss limit expressed as a percentage of the initial monthly balance. If this threshold is reached, trading will be halted until a new month begins.

---

## How It Works

### Initialization:
- On startup, the bot retrieves the current broker server time and calculates the appropriate UTC offset based on DST settings.
- A timer is set to trigger events at the start of each hour.

### Hourly Check (OnTimer Event):
- The bot updates the monthly balance at the beginning of a new month.
- It verifies if the current time matches one of the three defined entry times.
- It checks whether the account’s monthly profit or loss limits have been reached. If so, the bot stops trading for that month until the start of the next month.

### Data Collection and Order Placement:
- **CalculateHighLow:**  
  Retrieves the high, low, open, and close values from the 4-hour candle.
  
- **Order Creation (Order Class):**  
  Using the calculated values:
  - **Buy and Sell Orders:**  
    Limit orders are placed based on the candle’s high and low. When the market hits a defined level, the bot cancels the opposite order accordingly.
  - **Volume Calculation:**  
    Trade volume is calculated using the defined risk percentage and broker-specific lot sizes.

### Time Adjustments:
- **DST Detection (isDstActive):**  
  Checks if the current date falls within the DST period and applies the corresponding offset.
  
- **GetUtcTimeHour:**  
  Converts the current time to the target time zone (default New York time) using the appropriate offset.

### Order Management (OnTick Event):
- Continuously monitors market price ticks.
- Checks if active orders need to be canceled based on price movements.
- Manages the array of active orders by removing those that have been executed or canceled.

---

## Files Structure

- **Bash Scripts:**  
  - `deploy.sh`: Copies required MQL5 files to your MT5 directories.
  
- **MQL5 Files:**  
  - `main.mq5`: Main expert advisor file that initializes the bot.
  - `MyGlobals.mqh`: Global variables and shared constants.
  - `OrderPart.mqh`: Contains the Order class with functions for order creation and management.
  - `TimePart.mqh`: Functions for handling time-related calculations, DST adjustments, and timer setups.

---

## Installation

### Prerequisites
- **MetaTrader 5 (MT5) Terminal:** Compatible with LiteFinance or EXNESS versions.
- **Wine:** Required if you are running MT5 on Linux.
- Basic familiarity with MQL5 and trading bot setups.

### Setup Instructions
1. **Clone the Repository:**
   ```bash
   git clone https://github.com/yourusername/NY-9AM-Breakout-Bot.git
   cd NY-9AM-Breakout-Bot
