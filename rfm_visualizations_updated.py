"""
RFM Analysis - Data Visualization Script

Purpose: Generate insights visualizations from BigQuery RFM models
Author: Data Analytics Project 1
Date: Feb 10, 2025
"""

import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
from google.cloud import bigquery
import os

# ============================================================================
# CONFIGURATION
# ============================================================================

PROJECT_ID = "portfolio-ecommerce-486905"
DATASET = "analytics"

# Initialize BigQuery client
client = bigquery.Client(project=PROJECT_ID)

print("=" * 70)
print("RFM ANALYSIS - VISUALIZATION GENERATOR")
print("=" * 70)
print(f"Project: {PROJECT_ID}")
print(f"Dataset: {DATASET}")
print()

# ============================================================================
# DATA EXTRACTION
# ============================================================================

print("📊 Loading data from BigQuery...")

# Query 1: RFM Segment Distribution
query_segments = f"""
SELECT 
    customer_segment,
    COUNT(*) as customer_count,
    ROUND(AVG(monetary_value), 2) as avg_lifetime_value,
    ROUND(AVG(frequency_count), 1) as avg_orders,
    ROUND(AVG(recency_days), 0) as avg_days_since_last_order,
    ROUND(AVG(recency_score), 1) as avg_recency_score,
    ROUND(AVG(frequency_score), 1) as avg_frequency_score,
    ROUND(AVG(monetary_score), 1) as avg_monetary_score
FROM `{PROJECT_ID}.{DATASET}.fct_rfm_segments`
GROUP BY customer_segment
ORDER BY customer_count DESC
"""

df_segments = client.query(query_segments).to_dataframe()
print(f"✅ Loaded {len(df_segments)} customer segments")

# Query 2: Monthly Revenue by Segment (last 12 months)
query_revenue_trends = f"""
SELECT 
    DATE_TRUNC(f.order_date, MONTH) AS order_month,
    r.customer_segment,
    COUNT(DISTINCT f.order_id) AS total_orders,
    SUM(f.order_revenue) AS total_revenue
FROM `{PROJECT_ID}.{DATASET}.fct_orders` f
INNER JOIN `{PROJECT_ID}.{DATASET}.fct_rfm_segments` r
    ON f.user_id = r.user_id
WHERE f.status = 'Complete'
    AND f.order_date >= '2023-01-01'  -- Last 2 years of data
GROUP BY order_month, customer_segment
ORDER BY order_month DESC, total_revenue DESC
"""

df_revenue = client.query(query_revenue_trends).to_dataframe()
print(f"✅ Loaded {len(df_revenue)} revenue trend records")

# Query 3: RFM Score Distribution
query_rfm_scores = f"""
SELECT 
    recency_score,
    frequency_score,
    monetary_score,
    customer_segment,
    COUNT(*) as customer_count
FROM `{PROJECT_ID}.{DATASET}.fct_rfm_segments`
GROUP BY recency_score, frequency_score, monetary_score, customer_segment
ORDER BY customer_count DESC
LIMIT 50
"""

df_scores = client.query(query_rfm_scores).to_dataframe()
print(f"✅ Loaded {len(df_scores)} RFM score combinations")

print()

# ============================================================================
# VISUALIZATION 1: SEGMENT DISTRIBUTION
# ============================================================================

print("📈 Creating Visualization 1: Segment Distribution...")

# Sort by customer count for better visual
df_segments_sorted = df_segments.sort_values('customer_count', ascending=True)

fig1 = go.Figure()

fig1.add_trace(go.Bar(
    y=df_segments_sorted['customer_segment'],
    x=df_segments_sorted['customer_count'],
    orientation='h',
    marker=dict(
        color=df_segments_sorted['avg_lifetime_value'],
        colorscale='Blues',
        showscale=True,
        colorbar=dict(title="Avg LTV ($)")
    ),
    text=df_segments_sorted['customer_count'],
    textposition='outside',
    hovertemplate='<b>%{y}</b><br>' +
                  'Customers: %{x:,}<br>' +
                  'Avg LTV: $%{marker.color:.2f}<br>' +
                  '<extra></extra>'
))

fig1.update_layout(
    title={
        'text': "Customer Segment Distribution<br><sub>Size by count, Color by lifetime value</sub>",
        'x': 0.5,
        'xanchor': 'center'
    },
    xaxis_title="Number of Customers",
    yaxis_title="Customer Segment",
    height=600,
    template="plotly_white",
    showlegend=False
)

fig1.write_html("viz_1_segment_distribution.html")
print("✅ Saved: viz_1_segment_distribution.html")

# ============================================================================
# VISUALIZATION 2: SEGMENT METRICS COMPARISON
# ============================================================================

print("📈 Creating Visualization 2: Segment Metrics Comparison...")

fig2 = make_subplots(
    rows=2, cols=2,
    subplot_titles=("Average Lifetime Value", "Average Orders", 
                   "Days Since Last Order", "RFM Scores"),
    specs=[[{"type": "bar"}, {"type": "bar"}],
           [{"type": "bar"}, {"type": "bar"}]]
)

# Sort by LTV for consistent ordering
df_viz = df_segments.sort_values('avg_lifetime_value', ascending=False)

# Subplot 1: Lifetime Value
fig2.add_trace(
    go.Bar(x=df_viz['customer_segment'], y=df_viz['avg_lifetime_value'],
           name='Avg LTV', marker_color='#1f77b4'),
    row=1, col=1
)

# Subplot 2: Average Orders
fig2.add_trace(
    go.Bar(x=df_viz['customer_segment'], y=df_viz['avg_orders'],
           name='Avg Orders', marker_color='#ff7f0e'),
    row=1, col=2
)

# Subplot 3: Recency Days
fig2.add_trace(
    go.Bar(x=df_viz['customer_segment'], y=df_viz['avg_days_since_last_order'],
           name='Recency Days', marker_color='#2ca02c'),
    row=2, col=1
)

# Subplot 4: RFM Scores Stacked
fig2.add_trace(
    go.Bar(x=df_viz['customer_segment'], y=df_viz['avg_recency_score'],
           name='R Score', marker_color='#d62728'),
    row=2, col=2
)
fig2.add_trace(
    go.Bar(x=df_viz['customer_segment'], y=df_viz['avg_frequency_score'],
           name='F Score', marker_color='#9467bd'),
    row=2, col=2
)
fig2.add_trace(
    go.Bar(x=df_viz['customer_segment'], y=df_viz['avg_monetary_score'],
           name='M Score', marker_color='#8c564b'),
    row=2, col=2
)

fig2.update_layout(
    title_text="Customer Segment Metrics Overview",
    height=800,
    template="plotly_white",
    showlegend=True
)

fig2.update_xaxes(tickangle=45)
fig2.write_html("viz_2_segment_metrics.html")
print("✅ Saved: viz_2_segment_metrics.html")

# ============================================================================
# VISUALIZATION 3: REVENUE TRENDS BY SEGMENT
# ============================================================================

print("📈 Creating Visualization 3: Revenue Trends...")

# Focus on top 5 revenue-generating segments
top_segments = df_segments.nlargest(5, 'avg_lifetime_value')['customer_segment'].tolist()
df_revenue_filtered = df_revenue[df_revenue['customer_segment'].isin(top_segments)]

fig3 = px.line(
    df_revenue_filtered,
    x='order_month',
    y='total_revenue',
    color='customer_segment',
    title='Monthly Revenue by Top Customer Segments (2023-2024)',
    labels={'total_revenue': 'Total Revenue ($)', 'order_month': 'Month'},
    markers=True
)

fig3.update_layout(
    height=500,
    template="plotly_white",
    hovermode='x unified'
)

fig3.write_html("viz_3_revenue_trends.html")
print("✅ Saved: viz_3_revenue_trends.html")

# ============================================================================
# VISUALIZATION 4: RFM SCORE HEATMAP
# ============================================================================

print("📈 Creating Visualization 4: RFM Score Heatmap...")

# Create pivot for R vs F (aggregating M)
pivot_data = df_scores.groupby(['recency_score', 'frequency_score'])['customer_count'].sum().reset_index()
heatmap_matrix = pivot_data.pivot(index='frequency_score', columns='recency_score', values='customer_count')

fig4 = go.Figure(data=go.Heatmap(
    z=heatmap_matrix.values,
    x=heatmap_matrix.columns,
    y=heatmap_matrix.index,
    colorscale='YlOrRd',
    text=heatmap_matrix.values,
    texttemplate='%{text}',
    textfont={"size": 10},
    hovertemplate='Recency: %{x}<br>Frequency: %{y}<br>Customers: %{z}<extra></extra>'
))

fig4.update_layout(
    title='RFM Score Distribution: Recency vs Frequency<br><sub>Cell values show customer count</sub>',
    xaxis_title='Recency Score (5 = Most Recent)',
    yaxis_title='Frequency Score (5 = Most Frequent)',
    height=500,
    template="plotly_white"
)

fig4.write_html("viz_4_rfm_heatmap.html")
print("✅ Saved: viz_4_rfm_heatmap.html")

# ============================================================================
# SUMMARY REPORT
# ============================================================================

print()
print("=" * 70)
print("📊 SUMMARY STATISTICS")
print("=" * 70)
print(f"Total Customers Analyzed: {df_segments['customer_count'].sum():,}")
print(f"Number of Segments: {len(df_segments)}")
print()
print("Top 3 Segments by Size:")
for idx, row in df_segments.head(3).iterrows():
    print(f"  {row['customer_segment']:20s} - {row['customer_count']:,} customers (Avg LTV: ${row['avg_lifetime_value']:.2f})")
print()
print("Top 3 Segments by Lifetime Value:")
top_ltv = df_segments.nlargest(3, 'avg_lifetime_value')
for idx, row in top_ltv.iterrows():
    print(f"  {row['customer_segment']:20s} - ${row['avg_lifetime_value']:.2f} (Count: {row['customer_count']:,})")
print()
print("=" * 70)
print("✅ ALL VISUALIZATIONS GENERATED SUCCESSFULLY!")
print("=" * 70)
print()
print("📁 Output Files:")
print("  1. viz_1_segment_distribution.html")
print("  2. viz_2_segment_metrics.html")
print("  3. viz_3_revenue_trends.html")
print("  4. viz_4_rfm_heatmap.html")
print()
print("💡 Open these HTML files in your browser to view interactive charts!")
print("=" * 70)
