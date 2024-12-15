import tkinter as tk
from tkinter import ttk, messagebox
import oracledb
from movie_page import MoviePage  # Importer la classe MoviePage

# Database connection details
USERS = {
    "User1 (user1)": {"username": "user1", "role": "Read-Only Access"},
    "User2 (user2)": {"username": "user2", "role": "Limited Access"},
    "User3 (user3)": {"username": "user3", "role": "Full Access"},
}
DSN = "localhost/orclpdb1"

class LoginPage:
    def __init__(self, root):
        self.root = root
        self.root.title("Login Page")
        self.root.geometry("500x300")
        self.connection = None

        self.create_login_screen()

    def create_login_screen(self):
        """Create the login interface."""
        self.login_frame = tk.Frame(self.root)
        self.login_frame.pack(pady=50)

        tk.Label(self.login_frame, text="Select User:", font=("Arial", 12)).grid(row=0, column=0, padx=10, pady=5)
        self.user_selector = ttk.Combobox(self.login_frame, values=list(USERS.keys()), state="readonly")
        self.user_selector.grid(row=0, column=1, padx=10, pady=5)
        self.user_selector.bind("<<ComboboxSelected>>", self.show_permissions)

        self.permissions_label = tk.Label(self.login_frame, text="", font=("Arial", 10), wraplength=400, justify="left")
        self.permissions_label.grid(row=1, column=0, columnspan=2, padx=10, pady=10)

        tk.Label(self.login_frame, text="Password:", font=("Arial", 12)).grid(row=2, column=0, padx=10, pady=5)
        self.password_entry = tk.Entry(self.login_frame, show="*", font=("Arial", 12))
        self.password_entry.grid(row=2, column=1, padx=10, pady=5)

        tk.Button(self.login_frame, text="Connect", command=self.connect_to_db).grid(row=3, column=0, columnspan=2, pady=10)

    def show_permissions(self, event):
        """Show permissions for the selected user."""
        user = self.user_selector.get()
        if user:
            self.permissions_label.config(text=f"Permissions: {USERS[user]['role']}")
        else:
            self.permissions_label.config(text="")

    def connect_to_db(self):
        """Connect to the database and open the Movie Page."""
        user = self.user_selector.get()
        password = self.password_entry.get()

        if not user:
            messagebox.showerror("Error", "Please select a user.")
            return

        if not password.strip():
            messagebox.showerror("Error", "Please enter a password.")
            return

        credentials = USERS[user]
        try:
            self.connection = oracledb.connect(
                user=credentials["username"],
                password=password,
                dsn=DSN
            )
            messagebox.showinfo("Connection", f"Connected as {credentials['username']}.")

            # Open the movie page and close the login page
            self.root.destroy()  # Close login page
            root = tk.Tk()
            MoviePage(root, self.connection, credentials)
            root.mainloop()

        except oracledb.DatabaseError as e:
            error, = e.args
            messagebox.showerror("Error", f"Failed to connect to the database: {error.message}")


if __name__ == "__main__":
    root = tk.Tk()
    LoginPage(root)
    root.mainloop()


