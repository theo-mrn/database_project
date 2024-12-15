import pandas as pd
import oracledb

# Informations de connexion Oracle
dsn = "localhost/orclpdb1"
user = "admin_user"  # Connexion avec l'utilisateur admin_user
password = "AdminPassword123"

# Charger et nettoyer les données CSV
def load_and_clean_data(csv_path):
    data = pd.read_csv(csv_path)

    required_columns = [
        "id", "title", "original_title", "release_date", "status", "overview",
        "tagline", "homepage", "original_language", "runtime", "genres",
        "budget", "revenue", "vote_count", "vote_average", "popularity",
        "production_companies", "production_countries", "director"
    ]
    available_columns = [col for col in required_columns if col in data.columns]
    print(f"Colonnes disponibles pour l'insertion : {available_columns}")

    data = data.dropna(subset=available_columns)

    if "release_date" in data.columns:
        data['release_date'] = pd.to_datetime(data['release_date'], errors='coerce')
        data = data.dropna(subset=['release_date'])
        data['release_date'] = data['release_date'].dt.strftime('%d/%m/%Y')
    
    return data

# Insertion des données dans les tables
def insert_or_update_data(cleaned_data):
    try:
        connection = oracledb.connect(user=user, password=password, dsn=dsn)
        cursor = connection.cursor()
        print("Connexion réussie en tant que admin_user.")

        print("Insertion ou mise à jour des données...")
        for _, row in cleaned_data.iterrows():
            try:
                row["production_companies"] = row["production_companies"][:255] if len(row["production_companies"]) > 255 else row["production_companies"]
                row["production_countries"] = row["production_countries"][:100] if len(row["production_countries"]) > 100 else row["production_countries"]

                # Movies table
                sql_merge_movies = """
                MERGE INTO admin_user.Movies target
                USING (SELECT :1 AS id, :2 AS title, :3 AS original_title, TO_DATE(:4, 'DD/MM/YYYY') AS release_date,
                             :5 AS status, :6 AS overview, :7 AS tagline, :8 AS homepage,
                             :9 AS original_language, :10 AS runtime, :11 AS genres
                       FROM dual) source
                ON (target.id = source.id)
                WHEN MATCHED THEN
                    UPDATE SET title = source.title, original_title = source.original_title,
                               release_date = source.release_date, status = source.status,
                               overview = source.overview, tagline = source.tagline,
                               homepage = source.homepage, original_language = source.original_language,
                               runtime = source.runtime, genres = source.genres
                WHEN NOT MATCHED THEN
                    INSERT (id, title, original_title, release_date, status, overview,
                            tagline, homepage, original_language, runtime, genres)
                    VALUES (source.id, source.title, source.original_title, source.release_date,
                            source.status, source.overview, source.tagline, source.homepage,
                            source.original_language, source.runtime, source.genres)
                """
                cursor.execute(sql_merge_movies, (
                    row["id"], row["title"], row["original_title"], row["release_date"],
                    row["status"], row.get("overview"), row.get("tagline"), row.get("homepage"),
                    row["original_language"], row.get("runtime"), row.get("genres")
                ))

                # Financials table
                sql_merge_financials = """
                MERGE INTO admin_user.Financials target
                USING (SELECT :1 AS movie_id, :2 AS budget, :3 AS revenue FROM dual) source
                ON (target.movie_id = source.movie_id)
                WHEN MATCHED THEN
                    UPDATE SET budget = source.budget, revenue = source.revenue
                WHEN NOT MATCHED THEN
                    INSERT (movie_id, budget, revenue)
                    VALUES (source.movie_id, source.budget, source.revenue)
                """
                cursor.execute(sql_merge_financials, (row["id"], row["budget"], row["revenue"]))

                # Votes table
                sql_merge_votes = """
                MERGE INTO admin_user.Votes target
                USING (SELECT :1 AS movie_id, :2 AS vote_count, :3 AS vote_average, :4 AS popularity FROM dual) source
                ON (target.movie_id = source.movie_id)
                WHEN MATCHED THEN
                    UPDATE SET vote_count = source.vote_count, vote_average = source.vote_average, popularity = source.popularity
                WHEN NOT MATCHED THEN
                    INSERT (movie_id, vote_count, vote_average, popularity)
                    VALUES (source.movie_id, source.vote_count, source.vote_average, source.popularity)
                """
                cursor.execute(sql_merge_votes, (row["id"], row["vote_count"], row["vote_average"], row.get("popularity")))

                # Production table
                sql_merge_production = """
                MERGE INTO admin_user.Production target
                USING (SELECT :1 AS production_id, :2 AS movie_id, :3 AS production_company, :4 AS production_country FROM dual) source
                ON (target.production_id = source.production_id)
                WHEN MATCHED THEN
                    UPDATE SET production_company = source.production_company, production_country = source.production_country
                WHEN NOT MATCHED THEN
                    INSERT (production_id, movie_id, production_company, production_country)
                    VALUES (source.production_id, source.movie_id, source.production_company, source.production_country)
                """
                cursor.execute(sql_merge_production, (
                    _, row["id"], row["production_companies"], row["production_countries"]
                ))

                # People table
                sql_merge_people = """
                MERGE INTO admin_user.People target
                USING (SELECT :1 AS person_id, :2 AS movie_id, :3 AS name, :4 AS role FROM dual) source
                ON (target.person_id = source.person_id)
                WHEN MATCHED THEN
                    UPDATE SET name = source.name, role = source.role
                WHEN NOT MATCHED THEN
                    INSERT (person_id, movie_id, name, role)
                    VALUES (source.person_id, source.movie_id, source.name, source.role)
                """
                cursor.execute(sql_merge_people, (_, row["id"], row["director"], "Director"))

            except oracledb.DatabaseError as e:
                error, = e.args
                print(f"Erreur lors de l'insertion/mise à jour de la ligne ID={row['id']} : {error.message}")

        connection.commit()
        print("Toutes les données ont été insérées ou mises à jour avec succès.")

    except oracledb.DatabaseError as e:
        error, = e.args
        print(f"Erreur de connexion ou d'exécution : {error.message}")

    finally:
        if 'cursor' in locals():
            cursor.close()
        if 'connection' in locals():
            connection.close()
        print("Connexion fermée.")

# Script principal
if __name__ == "__main__":
    csv_path = "movies.csv"
    cleaned_data = load_and_clean_data(csv_path)
    insert_or_update_data(cleaned_data)
