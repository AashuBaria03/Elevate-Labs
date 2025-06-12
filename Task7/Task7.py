# Import libraries
import sqlite3
import pandas as pd
import matplotlib.pyplot as plt

# Step 1: Create and connect to the SQLite database
conn = sqlite3.connect("sales_data.db")
cursor = conn.cursor()

# Step 2: Create a sample sales table (only if not exists)
cursor.execute("""
CREATE TABLE IF NOT EXISTS sales (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    product TEXT,
    quantity INTEGER,
    price REAL
)
""")

# Step 3: Insert sample data (skip this if already added)
sample_data = [
    ('Product A', 10, 100.0),
    ('Product B', 5, 200.0),
    ('Product A', 8, 100.0),
    ('Product C', 7, 150.0),
    ('Product B', 3, 200.0),
    ('Product C', 5, 150.0),
]
cursor.executemany("INSERT INTO sales (product, quantity, price) VALUES (?, ?, ?)", sample_data)

# Commit changes
conn.commit()


# Step 4: Query for total quantity and revenue per product
query = """
SELECT 
    product, 
    SUM(quantity) AS total_qty, 
    SUM(quantity * price) AS revenue 
FROM sales 
GROUP BY product
"""

# Step 5: Load results into a DataFrame
df = pd.read_sql_query(query, conn)

# Step 6: Print summary table
print("=== Sales Summary ===")
print(df)

# Step 7: Plot bar chart for revenue per product
df.plot(kind='bar', x='product', y='revenue', legend=False)
plt.title("Revenue by Product")
plt.xlabel("Product")
plt.ylabel("Revenue")
plt.tight_layout()

# Optional: Save the chart
plt.savefig("sales_chart.png")
plt.show()

# Step 8: Close connection
conn.close()