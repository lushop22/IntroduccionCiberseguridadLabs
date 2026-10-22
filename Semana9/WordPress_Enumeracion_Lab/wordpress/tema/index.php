<!doctype html>
<html <?php language_attributes(); ?>>
<head><meta charset="<?php bloginfo('charset'); ?>"><title><?php bloginfo('name'); ?></title><?php wp_head(); ?></head>
<body <?php body_class(); ?>>
<header><h1><?php bloginfo('name'); ?></h1><p><?php bloginfo('description'); ?></p></header>
<nav><a href="<?php echo esc_url(home_url('/')); ?>">Inicio</a><a href="<?php echo esc_url(home_url('/contacto/')); ?>">Contacto</a><a href="<?php echo esc_url(home_url('/recursos/')); ?>">Recursos</a></nav>
<main>
<?php if (have_posts()) : while (have_posts()) : the_post(); ?>
<article><h2><a href="<?php the_permalink(); ?>"><?php the_title(); ?></a></h2>
<p>Autor: <?php the_author_posts_link(); ?></p><div><?php the_content(); ?></div></article>
<?php endwhile; else: ?><p>No hay contenido para esta consulta.</p><?php endif; ?>
</main><footer>Portal docente. Nombres, correos y datos ficticios.</footer>
<?php wp_footer(); ?></body></html>
