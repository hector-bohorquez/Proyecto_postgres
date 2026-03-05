# Proyecto_postgres

Este es un proyecto Flask que usa PostgreSQL como base de datos. Incluye un script `scriptDB_postgresql.sql` con las instrucciones para crear todas las tablas y datos iniciales.

## Preparación para desplegar en Render

1. Empuja el código a un repositorio Git (GitHub, GitLab, Bitbucket).
2. Asegúrate de que `requirements.txt` lista todas las dependencias (`Flask`, `psycopg[binary]`, `gunicorn`, etc.).
3. Incluye un `Procfile` (ya está en la raíz):
   ```
   web: gunicorn app:app
   ```
4. El archivo `runtime.txt` fija la versión de Python a usar. Render lo respeta.
5. Modifica las variables de entorno desde el panel de Render:
   - **DATABASE_URL**: viene proporcionada automáticamente cuando creas un servicio de Postgres o puedes extraerla de los detalles del servicio.
   - **SECRET_KEY**: una cadena aleatoria para la sesión de Flask.
   - (Opcional) MAIL_USERNAME, MAIL_PASSWORD, etc.

## Creación de tablas en la base de datos

Render no ejecuta automáticamente `scriptDB_postgresql.sql`. tienes varias opciones:

- **Manualmente desde tu máquina**:
  1. Instala `psql` localmente.
  2. Copia la conexión que Render da en el panel de la base de datos. Será algo como:
     `postgres://usuario:contraseña@host:puerto/nombrebd`
  3. Ejecuta:
     ```sh
     psql "$DATABASE_URL" -f scriptDB_postgresql.sql
     ```
     (reemplaza `$DATABASE_URL` por la cadena real o exporta la variable primero).

- **Durante el build en Render**: abre la configuración del servicio web y en `Build Command` agrega
  ```sh
  pip install -r requirements.txt && psql "$DATABASE_URL" -f scriptDB_postgresql.sql
  ```
  Esto hará que sea recreada cada vez que se construya (útil en entornos de staging). Si no desea sobrescribir datos, puedes envolverlo con `if`.

- **Automáticamente desde la aplicación**: añadir lógica al arranque para comprobar si las tablas existen y, si no, ejecutar el script. Por simplicidad actual, no se ha incluido, pero puedes implementar algo parecido a:
  ```python
  import subprocess, os
  def init_db():
      url = os.getenv('DATABASE_URL')
      if url:
          subprocess.run(['psql', url, '-f', 'scriptDB_postgresql.sql'])
  
  if __name__ == '__main__':
      init_db()
      app.run()
  ```

El método manual es suficiente para empezar.

## Despliegue

1. En el dashboard de Render crea un **Web Service** apuntando al repositorio y la rama.
2. Elige el entorno **Python**. Configura `Build Command` y `Start Command` (ambos ya indicados arriba).
3. Añade la base de datos de Render: `New > Database > PostgreSQL` y después ve al servicio web y haz `Add Database` seleccionando la BD creada.
4. Copia la variable `DATABASE_URL` y agrégala también como variable de entorno en el servicio web si no se hereda.
5. Despliega. Si usaste el paso de `psql` en el build, la base de datos se inicializará. Si no, hazlo manualmente como se explicó.

## Notas

- Render no conserva el sistema de archivos para subidas (`uploads/`). Considera usar un almacenamiento externo.
- El `scriptDB_postgresql.sql` también incluye datos de ejemplo (roles, usuarios) que se insertan cuando se ejecuta.
