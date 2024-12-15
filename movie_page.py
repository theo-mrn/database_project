import tkinter as tk
from tkinter import ttk, messagebox
import re
from graph_page import GraphPage  # Importation de la page des graphiques

class MoviePage:
    def __init__(self, root, connection, user_credentials):
        self.root = root
        self.root.title("Movie Database")
        self.root.geometry("1200x800")
        self.connection = connection
        self.cursor = self.connection.cursor()
        self.user_credentials = user_credentials

        self.tables = ["Movies", "Financials", "Votes", "Production", "People"]
        self.schema = "admin_user"

        self.create_main_interface()

    def normalize_query(self, query):
        for table in self.tables:
            query = re.sub(rf"(?i)(\bFROM\b|\bJOIN\b)\s+{table}\b", rf"\1 {self.schema}.{table}", query)
        return query

    def create_main_interface(self):
        self.main_frame = ttk.Frame(self.root, padding=20)
        self.main_frame.pack(fill=tk.BOTH, expand=True)

        self.header_frame = ttk.Frame(self.main_frame)
        self.header_frame.pack(fill=tk.X, pady=10)

        ttk.Label(
            self.header_frame,
            text=f"Welcome, {self.user_credentials['username']} ({self.user_credentials['role']})",
            font=("Arial", 14, "bold"),
        ).pack(side=tk.LEFT)

        ttk.Button(self.header_frame, text="Logout", command=self.logout).pack(side=tk.RIGHT)

        self.notebook = ttk.Notebook(self.main_frame)
        self.notebook.pack(fill=tk.BOTH, expand=True)

        self.create_movie_tab()
        self.create_graph_tab()

    def create_movie_tab(self):
        self.movie_tab = ttk.Frame(self.notebook)
        self.notebook.add(self.movie_tab, text="Movies")

        self.search_frame = ttk.LabelFrame(self.movie_tab, text="Search Movies", padding=10)
        self.search_frame.pack(fill=tk.X, pady=10)

        ttk.Label(self.search_frame, text="Movie Name:").pack(side=tk.LEFT, padx=5)
        self.search_entry = ttk.Entry(self.search_frame, width=50)
        self.search_entry.pack(side=tk.LEFT, padx=5)
        ttk.Button(self.search_frame, text="Search", command=self.search_movie).pack(side=tk.LEFT, padx=5)

        button_frame = ttk.Frame(self.movie_tab)
        button_frame.pack(pady=10)

        ttk.Button(button_frame, text="Load All Movies", command=self.load_all_movies).pack(side=tk.LEFT, padx=5)
        ttk.Button(button_frame, text="Custom Query", command=self.open_query_window).pack(side=tk.LEFT, padx=5)

        self.tree_frame = ttk.LabelFrame(self.movie_tab, text="Movie Details", padding=10)
        self.tree_frame.pack(fill=tk.BOTH, expand=True)

        self.tree = ttk.Treeview(self.tree_frame, show="headings", selectmode="browse")
        self.tree.pack(fill=tk.BOTH, expand=True, side=tk.LEFT)

        self.tree_scrollbar_y = ttk.Scrollbar(self.tree_frame, orient="vertical", command=self.tree.yview)
        self.tree_scrollbar_y.pack(side=tk.RIGHT, fill=tk.Y)
        self.tree_scrollbar_x = ttk.Scrollbar(self.movie_tab, orient="horizontal", command=self.tree.xview)
        self.tree_scrollbar_x.pack(side=tk.BOTTOM, fill=tk.X)

        self.tree.configure(yscrollcommand=self.tree_scrollbar_y.set, xscrollcommand=self.tree_scrollbar_x.set)

    def create_graph_tab(self):
        self.graph_tab = ttk.Frame(self.notebook)
        self.notebook.add(self.graph_tab, text="Graphs")

        GraphPage(self.graph_tab, self.connection)

    def open_query_window(self):
        """Open a new window for custom query execution."""
        query_window = tk.Toplevel(self.root)
        query_window.title("Custom Query")
        query_window.geometry("800x600")

        ttk.Label(query_window, text="Write your SQL Query below:", font=("Arial", 12)).pack(pady=10)

        query_text = tk.Text(query_window, wrap=tk.WORD, font=("Arial", 10))
        query_text.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)

        execute_button = ttk.Button(query_window, text="Execute", command=lambda: self.execute_custom_query(query_text, query_window))
        execute_button.pack(pady=10)

    def execute_custom_query(self, query_text, query_window):
        """Execute the custom query entered in the query window."""
        query = query_text.get("1.0", tk.END).strip()
        if not query:
            messagebox.showerror("Error", "Please enter a query.", parent=query_window)
            return

        try:
            query = self.normalize_query(query)
            self.cursor.execute(query)

            if query.strip().upper().startswith("SELECT"):
                rows = self.cursor.fetchall()
                columns = [desc[0] for desc in self.cursor.description]
                self.populate_tree(rows, columns)
                messagebox.showinfo("Success", "Query executed successfully.", parent=query_window)
            else:
                self.connection.commit()
                messagebox.showinfo("Success", "Query executed successfully.", parent=query_window)
        except Exception as e:
            messagebox.showerror("Error", f"Error executing query: {e}", parent=query_window)

    def search_movie(self):
        movie_name = self.search_entry.get()
        if not movie_name.strip():
            messagebox.showerror("Error", "Please enter a movie name to search.")
            return

        try:
            query = f"""
                SELECT m.id, m.title, m.release_date, m.status, m.runtime, m.genres
                FROM Movies m
                WHERE LOWER(m.title) LIKE :1
            """
            query = self.normalize_query(query)
            self.cursor.execute(query, [f"%{movie_name.lower()}%"])
            rows = self.cursor.fetchall()

            self.populate_tree(rows, ["ID", "Title", "Release Date", "Status", "Runtime", "Genres"])

        except Exception as e:
            messagebox.showerror("Error", f"Error searching for movie: {e}")

    def load_all_movies(self):
        try:
            query = "SELECT id, title, release_date, status, runtime, genres FROM Movies"
            query = self.normalize_query(query)
            self.cursor.execute(query)
            rows = self.cursor.fetchall()

            self.populate_tree(rows, ["ID", "Title", "Release Date", "Status", "Runtime", "Genres"])

        except Exception as e:
            messagebox.showerror("Error", f"Error loading movies: {e}")

    def populate_tree(self, rows, columns):
        self.tree.delete(*self.tree.get_children())
        self.tree["columns"] = columns

        for col in columns:
            self.tree.heading(col, text=col)
            self.tree.column(col, width=150, anchor="center")

        for row in rows:
            self.tree.insert("", tk.END, values=row)

    def logout(self):
        if messagebox.askyesno("Logout", "Are you sure you want to logout?"):
            self.root.destroy()
