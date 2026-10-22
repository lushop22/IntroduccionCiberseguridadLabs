#!/usr/bin/env python3
"""CampusLab: objetivo docente local con fallos intencionales de acceso."""
import json
import os
import secrets
from html import escape
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlsplit

KEY = os.environ.get('CAMPUS_KEY', 'DEMO-CAMPUS-74B2-2026')
PORT = int(os.environ.get('CAMPUS_PORT', '8000'))
STYLE = '<style>body{font:19px Arial,sans-serif;max-width:850px;margin:45px auto;padding:20px;color:#183c50}a{color:#007b9b}nav a{margin-right:22px}pre{background:#eef5f7;padding:18px;white-space:pre-wrap}footer{margin-top:45px;font-size:14px;color:#555}</style>'

def page(title, body):
    return ('<!doctype html><html lang="es"><head><meta charset="utf-8">'
            '<meta name="viewport" content="width=device-width,initial-scale=1">'
            '<title>'+title+'</title>'+STYLE+'</head><body>'
            '<h1>'+title+'</h1><nav><a href="/">Inicio</a><a href="/agenda">Agenda</a>'
            '<a href="/contacto">Contacto</a><a href="/documentos">Documentos</a></nav>'
            +body+'<footer>CampusLab: entorno docente, información totalmente ficticia.</footer></body></html>')

DOCUMENTS = {
    1001: {'id':1001, 'titulo':'Guía de bienvenida', 'clasificacion':'publico',
           'contenido':'Horarios de orientación y actividades ficticias del campus.'},
    1002: {'id':1002, 'titulo':'Presupuesto de actividades', 'clasificacion':'restringido',
           'contenido':'Presupuesto ficticio: 4800 unidades. Responsable: Comité Demo.',
           'bandera':'CAMPUS{DOCUMENTO_SIN_AUTORIZACION}'},
    1003: {'id':1003, 'titulo':'Plan interno de operaciones', 'clasificacion':'restringido',
           'contenido':'Documento ficticio que sí exige la clave del panel.'}
}

class Handler(BaseHTTPRequestHandler):
    server_version = 'CampusLabHTTP/1.0'
    sys_version = ''

    def log_message(self, fmt, *args):
        pass

    def send(self, status, body, kind='text/html; charset=utf-8', headers=None):
        if isinstance(body, dict):
            body=json.dumps(body, ensure_ascii=False, indent=2)+'\n'
            kind='application/json; charset=utf-8'
        data=body.encode('utf-8')
        self.send_response(status)
        self.send_header('Content-Type',kind)
        self.send_header('Content-Length',str(len(data)))
        self.send_header('Cache-Control','no-store')
        self.send_header('X-Campus-Entorno','pruebas')
        for k,v in (headers or {}).items():
            self.send_header(k,v)
        self.end_headers()
        if self.command!='HEAD':
            self.wfile.write(data)
        print(json.dumps({'hora':datetime.now(timezone.utc).isoformat(),
                          'origen':self.client_address[0], 'metodo':self.command,
                          'ruta':urlsplit(self.path).path,'estado':status},ensure_ascii=False),flush=True)

    def has_key(self):
        return secrets.compare_digest(self.headers.get('X-Campus-Key',''),KEY)

    def do_HEAD(self):
        self.do_GET()

    def do_GET(self):
        path=urlsplit(self.path).path
        if path=='/':
            return self.send(200,page('CampusLab - Actividades',
                '<p>Portal de actividades, orientación y documentos del campus.</p>'
                '<p id="estado">Consultando disponibilidad del portal...</p>'
                '<!-- build: campus-web-2.4 -->'
                '<script src="/assets/site.js"></script>'))
        if path=='/agenda':
            return self.send(200,page('Agenda', '<p>Jornada de orientación: lunes, 09:00.</p><p>Feria de proyectos: miércoles, 11:00.</p>'))
        if path=='/contacto':
            return self.send(200,page('Contacto','<p>Equipo responsable: Comité Campus Demo.</p><p>Correo ficticio: campus.soporte@example.test</p>'))
        if path=='/documentos':
            return self.send(200,page('Documentos públicos',
                '<p>Material publicado para visitantes.</p><a href="/api/documentos/1001">Guía de bienvenida</a>'))
        if path=='/assets/site.js':
            return self.send(200,'const estadoUrl = "/api/estado";\nfetch(estadoUrl).then(r=>r.json()).then(d=>{document.getElementById("estado").textContent="Portal: "+d.estado;});\n','application/javascript; charset=utf-8')
        if path=='/api/estado':
            return self.send(200,{'aplicacion':'CampusLab','version':'2.4-demo','entorno':'pruebas','estado':'disponible'})
        if path=='/robots.txt':
            return self.send(200,'User-agent: *\nDisallow: /archivo/\nDisallow: /interno/\nSitemap: /sitemap.xml\n','text/plain; charset=utf-8')
        if path=='/sitemap.xml':
            base='http://'+escape(self.headers.get('Host','127.0.0.1:8081'))
            xml='<?xml version="1.0"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'
            xml+=''.join('<url><loc>'+base+p+'</loc></url>' for p in ('/','/agenda','/contacto','/documentos'))
            return self.send(200,xml+'</urlset>','application/xml; charset=utf-8')
        if path=='/archivo':
            return self.send(301,'',headers={'Location':'/archivo/'})
        if path=='/archivo/':
            return self.send(200,page('Archivo del sitio','<p>Documentos conservados de la migración.</p><a href="/archivo/migracion.txt">migracion.txt</a>'))
        if path=='/archivo/migracion.txt':
            return self.send(200,'MIGRACIÓN DEL PORTAL - BORRADOR\nLa interfaz nueva utiliza /api/estado.\nLa compatibilidad del equipo de soporte sigue publicada en /legacy/config.json.\nRevisar esa configuración antes de pasar a producción.\nReferencia de inventario: CAMPUS{RASTRO_DE_MIGRACION}\n','text/plain; charset=utf-8')
        if path=='/legacy/config.json':
            return self.send(200,{'aplicacion':'CampusLab','entorno':'pruebas',
                'panel':'/api/panel','cabecera':'X-Campus-Key','clave_demo':KEY,
                'nota':'Configuración antigua de soporte. Datos ficticios.',
                'bandera':'CAMPUS{CONFIGURACION_PUBLICADA}'})
        if path=='/api/panel':
            if not self.has_key():
                return self.send(403,{'error':'Acceso denegado. Se requiere la credencial de soporte.'})
            return self.send(200,{'panel':'Coordinación interna', 'rol':'soporte',
                'inscritos_ficticios':84,'presupuesto_ficticio':4800,
                'documentos_internos':[1002,1003],
                'bandera':'CAMPUS{CLAVE_REUTILIZADA_EN_PANEL}'})
        if path.startswith('/api/documentos/'):
            raw=path.removeprefix('/api/documentos/')
            if not raw.isdecimal() or len(raw)>5:
                return self.send(404,{'error':'Documento no encontrado'})
            ident=int(raw);document=DOCUMENTS.get(ident)
            if document is None:
                return self.send(404,{'error':'Documento no encontrado'})
            # Fallo intencional: el documento 1002 omite comprobar autorización.
            if ident==1003 and not self.has_key():
                return self.send(403,{'error':'Acceso denegado'})
            return self.send(200,document)
        if path=='/interno' or path.startswith('/interno/'):
            return self.send(403,page('Acceso denegado','<p>La sección interna no está disponible para visitantes.</p>'))
        return self.send(404,page('No encontrado','<p>El recurso solicitado no existe.</p>'))

if __name__=='__main__':
    print(json.dumps({'evento':'inicio','puerto':PORT,'aplicacion':'CampusLab'}),flush=True)
    ThreadingHTTPServer(('0.0.0.0',PORT),Handler).serve_forever()
