1\. Exchange Rate API



Use a standard rates endpoint:

GET /latest?base={BASE}\&symbols={CSV}



Example:

GET https://api.example.com/latest?base=EUR\&symbols=THB,JPY,CNY



Response:

{

&nbsp; "base": "EUR",

&nbsp; "date": "2025-11-25",

&nbsp; "rates": {

&nbsp;   "THB": 39.1234,

&nbsp;   "JPY": 160.9876,

&nbsp;   "CNY": 7.4567

&nbsp; }

}



App writes rates into local DB.



2\. Conversion Logic



converted = amount \* multiplier



Where

multiplier = rate of foreignCurrency → homeCurrency



Decimals follow home currency formatting.



3\. Local Database Schema



| Field             | Type       | Description |

| ----------------- | ---------- | ----------- |

| id                | INTEGER PK | always 1    |

| home\_currency     | TEXT       | ISO code    |

| last\_rates\_update | TEXT       | ISO8601     |

| ads\_enabled       | INTEGER    | 1/0         |

| premium           | INTEGER    | 1/0         |



Table: cards



| Field       | Type       |

| ----------- | ---------- |

| id          | INTEGER PK |

| currency    | TEXT       |

| amount      | REAL       |

| title       | TEXT       |

| order\_index | INTEGER    |





