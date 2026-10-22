#!/bin/sh
set -eu
URL="http://127.0.0.1:${HTTP_PORT:-8082}"
attempt=0
while [ ! -f wp-config.php ] || [ ! -f wp-load.php ]; do
  attempt=$((attempt+1))
  if [ "$attempt" -ge 60 ]; then
    echo 'WordPress no terminó de preparar sus archivos.' >&2
    exit 1
  fi
  sleep 1
done
if ! wp core is-installed >/dev/null 2>&1; then
  wp core install --url="$URL" --title='CampusPress - Portal del taller' \
    --admin_user=docente --admin_password="$WP_ADMIN_PASSWORD" \
    --admin_email=docente@example.test --skip-email
fi
wp option update home "$URL"
wp option update siteurl "$URL"
wp option update blogdescription 'Aprender a observar servicios y contenido publico'
wp option update blog_public 1
mkdir -p wp-content/themes/campuspress wp-content/plugins/campus-agenda
cp -R /material/tema/. wp-content/themes/campuspress/
cp -R /material/plugin/. wp-content/plugins/campus-agenda/
wp theme activate campuspress
wp plugin activate campus-agenda
if ! wp user get lucia_redaccion --field=ID >/dev/null 2>&1; then
  wp user create lucia_redaccion lucia@example.test --role=author \
    --display_name='Lucia Demo' --user_pass="$WP_AUTHOR_PASSWORD"
fi
if ! wp user get mateo_agenda --field=ID >/dev/null 2>&1; then
  wp user create mateo_agenda mateo@example.test --role=author \
    --display_name='Mateo Demo' --user_pass="$WP_AUTHOR_PASSWORD"
fi
LUCIA="$(wp user get lucia_redaccion --field=ID)"
MATEO="$(wp user get mateo_agenda --field=ID)"
if [ "$(wp option get campus_seed_v1 2>/dev/null || true)" != listo ]; then
  wp post create --post_type=post --post_status=publish --post_author="$LUCIA" \
    --post_title='Bienvenidos al taller de redes' --post_name=bienvenida \
    --post_content='<p>Aprendemos a observar servicios y paginas publicas.</p>'
  wp post create --post_type=post --post_status=publish --post_author="$MATEO" \
    --post_title='Agenda de actividades' --post_name=agenda \
    --post_content='[campus_agenda]'
  wp post create --post_type=page --post_status=publish --post_title=Contacto \
    --post_name=contacto --post_content='<p>Equipo Campus Demo. Contacto ficticio: campus@example.test.</p>'
  wp post create --post_type=page --post_status=publish --post_title=Recursos \
    --post_name=recursos --post_content='<p>Material publico: <a href="/material/">archivos del taller</a>.</p>'
  wp option update campus_seed_v1 listo
fi
wp rewrite structure '/%postname%/'
cat > .htaccess <<'HTACCESS'
# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
# END WordPress
HTACCESS
mkdir -p material
printf '%s\n' 'equipo,funcion' 'PC-DEMO-01,Practica de redes' 'SRV-DEMO-01,Servidor ficticio' > material/inventario.csv
printf '%s\n' 'Portal de practica. Equipo Campus Demo. Datos ficticios.' > material/guia.txt
printf '%s\n' 'Options +Indexes' > material/.htaccess
printf '%s\n' 'User-agent: *' 'Disallow: /wp-admin/' 'Allow: /wp-admin/admin-ajax.php' "Sitemap: $URL/wp-sitemap.xml" > robots.txt
wp core version
wp user list --fields=ID,user_login,display_name --format=table
wp theme list --fields=name,status,version --format=table
wp plugin list --fields=name,status,version --format=table
echo "WordPress preparado: $URL"
