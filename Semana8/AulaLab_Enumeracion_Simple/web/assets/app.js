// Archivo de ejemplo que se entrega al navegador.
const estadoUrl = "/api/estado.json";
fetch(estadoUrl)
  .then(respuesta => respuesta.json())
  .then(datos => {
    document.getElementById("estado").textContent =
      "Aplicación: " + datos.aplicacion + " | Entorno: " + datos.entorno;
  });
