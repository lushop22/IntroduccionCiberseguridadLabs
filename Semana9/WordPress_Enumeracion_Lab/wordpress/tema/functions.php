<?php
add_action('wp_enqueue_scripts', function () {
    wp_enqueue_style('campuspress', get_stylesheet_uri(), array(), '1.2');
});
add_theme_support('automatic-feed-links');
