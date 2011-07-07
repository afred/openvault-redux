<?php
/**
 * The Header for our theme.
 *
 * Displays all of the <head> section and everything up till <div id="main">
 *
 * @package WordPress
 * @subpackage Twenty Eleven
 * @since Twenty Eleven 1.0
 */
?><!DOCTYPE html>
<!--[if IE 6]>
<html id="ie6" <?php language_attributes(); ?>>
<![endif]-->
<!--[if IE 7]>
<html id="ie7" <?php language_attributes(); ?>>
<![endif]-->
<!--[if IE 8]>
<html id="ie8" <?php language_attributes(); ?>>
<![endif]-->
<!--[if !(IE 6) | !(IE 7) | !(IE 8)  ]><!-->
<html <?php language_attributes(); ?>>
<!--<![endif]-->
<head>
<meta charset="<?php bloginfo( 'charset' ); ?>" />
<meta name="viewport" content="width=device-width" />
<title><?php
	/*
	 * Print the <title> tag based on what is being viewed.
	 */
	global $page, $paged;

	wp_title( '|', true, 'right' );

	// Add the blog name.
	bloginfo( 'name' );

	// Add the blog description for the home/front page.
	$site_description = get_bloginfo( 'description', 'display' );
	if ( $site_description && ( is_home() || is_front_page() ) )
		echo " | $site_description";

	// Add a page number if necessary:
	if ( $paged >= 2 || $page >= 2 )
		echo ' | ' . sprintf( __( 'Page %s', 'twentyeleven' ), max( $paged, $page ) );

	?></title>
<link rel="profile" href="http://gmpg.org/xfn/11" />
<link rel="stylesheet" type="text/css" media="all" href="<?php bloginfo( 'stylesheet_url' ); ?>" />
<link rel="pingback" href="<?php bloginfo( 'pingback_url' ); ?>" />
<!--[if lt IE 9]>
<script src="<?php echo get_template_directory_uri(); ?>/js/html5.js" type="text/javascript"></script>
<![endif]-->
<?php
	/* We add some JavaScript to pages with the comment form
	 * to support sites with threaded comments (when in use).
	 */
	if ( is_singular() && get_option( 'thread_comments' ) )
		wp_enqueue_script( 'comment-reply' );

	/* Always have wp_head() just before the closing </head>
	 * tag of your theme, or you will break many plugins, which
	 * generally use this hook to add elements to <head> such
	 * as styles, scripts, and meta tags.
	 */
	wp_head();
?>
<script type="text/javascript">
jQuery(function() {
  jQuery('#browse input').hide();
   jQuery('#browse select').bind('change', function() {
     jQuery(this).closest('form').submit();
   });

  jQuery('.user_util_links').load('/user_util_links');
});
</script>
</head>

<body <?php body_class(); ?>>
<div id="page" class="hfeed">
	<header id="branding" role="banner">
			<hgroup>
				<h1 id="site-title"><span><a href="/" title="<?php echo esc_attr( get_bloginfo( 'name', 'display' ) ); ?>" rel="home"><?php bloginfo( 'name' ); ?></a></span></h1>
				<h2 id="site-description"><?php bloginfo( 'description' ); ?></h2>
			</hgroup>

			<?php
				// Check to see if the header image has been removed
				$header_image = get_header_image();
				if ( ! empty( $header_image ) ) :
			?>
			<a href="<?php echo home_url( '/' ); ?>">
				<?php
					// The header image
					// Check if this is a post or page, if it has a thumbnail, and if it's a big one
					if ( is_singular() &&
							has_post_thumbnail( $post->ID ) &&
							( /* $src, $width, $height */ $image = wp_get_attachment_image_src( get_post_thumbnail_id( $post->ID ), 'post-thumbnail' ) ) &&
							$image[1] >= HEADER_IMAGE_WIDTH ) :
						// Houston, we have a new header image!
						echo get_the_post_thumbnail( $post->ID, 'post-thumbnail' );
					else : ?>
					<img src="<?php header_image(); ?>" width="<?php echo HEADER_IMAGE_WIDTH; ?>" height="<?php echo HEADER_IMAGE_HEIGHT; ?>" alt="" />
				<?php endif; // end check for featured image or standard header ?>
			</a>
			<?php endif; // end check for removed header image ?>

			<?php
				// Has the text been hidden?
				if ( 'blank' == get_header_textcolor() ) :
			?>
				<div class="only-search<?php if ( ! empty( $header_image ) ) : ?> with-image<?php endif; ?>">
				<?php get_search_form(); ?>
				</div>
			<?php
				else :
			?>
				<?php get_search_form(); ?>
			<?php endif; ?>

			<div class="user_util_links"></div>

			<nav id="access" role="navigation">
				<h1 class="section-heading"><?php _e( 'Main menu', 'twentyeleven' ); ?></h1>
				<?php /*  Allow screen readers / text browsers to skip the navigation menu and get right to the good stuff. */ ?>
				<div class="skip-link screen-reader-text"><a href="#content" title="<?php esc_attr_e( 'Skip to content', 'twentyeleven' ); ?>"><?php _e( 'Skip to content', 'twentyeleven' ); ?></a></div>
				<?php /* Our navigation menu.  If one isn't filled out, wp_nav_menu falls back to wp_page_menu. The menu assiged to the primary position is the one used. If none is assigned, the menu with the lowest ID is used. */ ?>
				<?php wp_nav_menu( array( 'theme_location' => 'primary' ) ); ?>
			</nav><!-- #access -->
<div id="search-bar">
<div id="search" class="search">
  <form accept-charset="UTF-8" action="/catalog" method="get"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="✓"></div>
    <h2 class="search"><label for="q">Search Archive</label></h2>
    <div class="q_field">
      <input class="q" id="q" name="q" placeholder="Search Archive" type="text">
    
    <input id="search_field" name="search_field" type="hidden" value="all_fields">
            
    
    <input alt="search" class="submit" src="/images/magnifying-glass.gif?1304697733" type="image">
  </div>
  
</form>
  <hr>
</div>

<div id="browse">
  <h2 class="search">Browse Archive</h2>
    <form accept-charset="UTF-8" action="/catalog" class="categories" method="get"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="✓" style="display: none; "></div>
      <select id="f_merlot_s" name="f[merlot_s][]"><option value="">Categories</option>
<optgroup label="Categories"><option value="Arts">Arts</option>
<option value="Business">Business</option>
<option value="Education">Education</option>
<option value="Humanities">Humanities</option>
<option value="Massachusetts">Massachusetts</option>
<option value="Science &amp; Technology">Science &amp; Technology</option>
<option value="Social Sciences">Social Sciences</option></optgroup></select>
      <input name="commit" type="submit" value="Browse Category" >
</form>
    <form accept-charset="UTF-8" action="/catalog" class="collections" method="get"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="✓" style="display: none; "></div>
      <select id="id_" name="id[]"><option value="">Collections and Series</option>
<optgroup label="Collections"><option value="march-march-on-washington">March on Washington</option>
<option value="prpe-press-and-the-people">Press and the People</option>
<option value="sbro-say-brother">Say Brother</option>
<option value="ntw-the-new-television-workshop">The New Television Workshop</option>
<option value="tocn-the-ten-o-clock-news">The Ten O'Clock News</option>
<option value="vietnam-the-vietnam-collection">The Vietnam Collection</option>
<option value="wpna-war-and-peace-in-the-nuclear-age">War and Peace in the Nuclear Age</option></optgroup><optgroup label="Series"><option value="ntw-aliv-alive-from-off-center">Alive From Off Center</option>
<option value="amex-american-experience">American Experience</option>
<option value="ntw-plah-american-playhouse">American Playhouse</option>
<option value="ntw-arsc-artist-s-showcase">Artist’s Showcase</option>
<option value="tocn-cwky-compass-weekly-the">Compass Weekly, The</option>
<option value="ntw-catf-contemporary-art-fund-cat">Contemporary Art Fund (CAT)</option>
<option value="ntw-danc-dance-for-camera">Dance for Camera</option>
<option value="ntw-darc-design-archiving-project">Design Archiving Project</option>
<option value="tocn-evco-evening-compass-the">Evening Compass, The</option>
<option value="ntw-frar-frames-of-reference">Frames of Reference</option>
<option value="ntw-miwk-music-image-workshop">Music Image Workshop</option>
<option value="ntw-ntvw-new-television-workshop">New Television Workshop</option>
<option value="ntw-poeb-poetry-breaks">Poetry Breaks</option>
<option value="ntw-ratv-rockefeller-artists-in-television">Rockefeller Artists in Television</option>
<option value="sbro-sayb-say-brother">Say Brother</option>
<option value="ntw-sond-soundings">Soundings</option>
<option value="ntw-twca-twentieth-century-artists">Twentieth Century Artists</option>
<option value="ntw-visi-visions">Visions</option></optgroup></select>
      <input name="commit" type="submit" value="Browse collection">
</form></div>
</div>
	</header><!-- #branding -->


	<div id="main">
