import tkinter as tk
from tkinter import ttk, messagebox
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg

class GraphPage:
    def __init__(self, parent, connection):
        self.parent = parent
        self.connection = connection

        self.create_graph_interface()

    def create_graph_interface(self):
        """Create the graph interface."""
        self.label = ttk.Label(self.parent, text="Select a graph to display", font=("Arial", 16))
        self.label.pack(pady=10)

        self.button_frame = ttk.Frame(self.parent)
        self.button_frame.pack(pady=10)

        ttk.Button(self.button_frame, text="Top 10 Movies by Revenue", command=self.plot_top_movies_by_revenue).pack(side=tk.LEFT, padx=5)
        ttk.Button(self.button_frame, text="Revenue vs Budget", command=self.plot_revenue_vs_budget).pack(side=tk.LEFT, padx=5)
        ttk.Button(self.button_frame, text="Vote Average Distribution", command=self.plot_vote_average_distribution).pack(side=tk.LEFT, padx=5)
        ttk.Button(self.button_frame, text="Top 10 Movies by Popularity", command=self.plot_top_movies_by_popularity).pack(side=tk.LEFT, padx=5)
        ttk.Button(self.button_frame, text="Top Directors by Movie Count", command=self.plot_top_directors_by_movies).pack(side=tk.LEFT, padx=5)

        self.graph_frame = ttk.Frame(self.parent)
        self.graph_frame.pack(fill=tk.BOTH, expand=True)

    def execute_query(self, query):
        """Execute a SQL query and return the results."""
        try:
            cursor = self.connection.cursor()
            cursor.execute(query)
            return cursor.fetchall()
        except Exception as e:
            messagebox.showerror("Error", f"Failed to execute query: {e}")
            return []

    def plot_top_movies_by_revenue(self):
        """Plot a bar chart of the top 10 movies by revenue."""
        query = """
        SELECT title, revenue
        FROM Movies m
        JOIN Financials f ON m.id = f.movie_id
        WHERE f.revenue IS NOT NULL
        ORDER BY f.revenue DESC
        FETCH FIRST 10 ROWS ONLY
        """
        data = self.execute_query(query)
        movies = [row[0] for row in data]
        revenues = [row[1] for row in data]

        self.show_bar_chart(movies, revenues, "Top 10 Movies by Revenue", "Movie Title", "Revenue")

    def plot_revenue_vs_budget(self):
        """Plot a scatter plot of revenue vs budget."""
        query = "SELECT budget, revenue FROM Financials WHERE budget > 0 AND revenue > 0"
        data = self.execute_query(query)
        budgets = [row[0] for row in data]
        revenues = [row[1] for row in data]

        self.show_scatter_plot(budgets, revenues, "Revenue vs Budget", "Budget", "Revenue")

    def plot_vote_average_distribution(self):
        """Plot a histogram of vote averages."""
        query = "SELECT vote_average FROM Votes"
        data = self.execute_query(query)
        vote_averages = [row[0] for row in data]

        self.show_histogram(vote_averages, "Vote Average Distribution", "Vote Average", "Frequency")

    def plot_top_movies_by_popularity(self):
        """Plot a bar chart of the top 10 movies by popularity."""
        query = """
        SELECT title, popularity
        FROM Movies m
        JOIN Votes v ON m.id = v.movie_id
        WHERE v.popularity IS NOT NULL
        ORDER BY v.popularity DESC
        FETCH FIRST 10 ROWS ONLY
        """
        data = self.execute_query(query)
        movies = [row[0] for row in data]
        popularities = [row[1] for row in data]

        self.show_bar_chart(movies, popularities, "Top 10 Movies by Popularity", "Movie Title", "Popularity")

    def plot_top_directors_by_movies(self):
        """Plot a bar chart of the top directors by number of movies."""
        query = """
        SELECT name AS director, COUNT(*) AS movie_count
        FROM People
        WHERE role = 'Director'
        GROUP BY name
        ORDER BY movie_count DESC
        FETCH FIRST 10 ROWS ONLY
        """
        data = self.execute_query(query)
        directors = [row[0] for row in data]
        movie_counts = [row[1] for row in data]

        self.show_bar_chart(directors, movie_counts, "Top Directors by Movie Count", "Director", "Number of Movies")

    def show_bar_chart(self, x_data, y_data, title, xlabel, ylabel):
        """Display a bar chart."""
        self.clear_graph_frame()
        fig, ax = plt.subplots()
        ax.bar(x_data, y_data)
        ax.set_title(title)
        ax.set_xlabel(xlabel)
        ax.set_ylabel(ylabel)
        ax.tick_params(axis="x", rotation=45)

        self.display_figure(fig)

    def show_scatter_plot(self, x_data, y_data, title, xlabel, ylabel):
        """Display a scatter plot."""
        self.clear_graph_frame()
        fig, ax = plt.subplots()
        ax.scatter(x_data, y_data)
        ax.set_title(title)
        ax.set_xlabel(xlabel)
        ax.set_ylabel(ylabel)

        self.display_figure(fig)

    def show_histogram(self, data, title, xlabel, ylabel):
        """Display a histogram."""
        self.clear_graph_frame()
        fig, ax = plt.subplots()
        ax.hist(data, bins=10, edgecolor="black")
        ax.set_title(title)
        ax.set_xlabel(xlabel)
        ax.set_ylabel(ylabel)

        self.display_figure(fig)

    def clear_graph_frame(self):
        """Clear the graph frame for a new graph."""
        for widget in self.graph_frame.winfo_children():
            widget.destroy()

    def display_figure(self, fig):
        """Display a Matplotlib figure in the graph frame."""
        canvas = FigureCanvasTkAgg(fig, master=self.graph_frame)
        canvas.draw()
        canvas.get_tk_widget().pack(fill=tk.BOTH, expand=True)