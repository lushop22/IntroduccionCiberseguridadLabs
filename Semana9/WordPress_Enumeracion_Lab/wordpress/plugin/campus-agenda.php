<?php
/*
Plugin Name: Campus Agenda
Description: Componente docente de agenda publica.
Version: 1.0
Author: Equipo Campus Demo
*/
add_action('wp_enqueue_scripts', function () {
    wp_enqueue_style('campus-agenda', plugins_url('agenda.css', __FILE__), array(), '1.0');
});
add_shortcode('campus_agenda', function () {
    return '<p class="campus-agenda">Taller de redes: lunes 09:00. Datos de demostracion.</p>';
});
