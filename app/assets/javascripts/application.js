//This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require_tree ./application
//= require openvault/browse

/* Blacklight default behavior is to collapse all facets; Open Vault facets are all open by default */ 
Blacklight.do_facet_expand_contract_behavior.selector = '#facets h3';

Blacklight.facet_expand_contract = function() {
  $(this).next("ul, div").each(function(){
    var f_content = $(this);
    $(f_content).prev('h3').addClass('twiddle twiddle-open');

    // attach the toggle behavior to the h3 tag
    $('h3', f_content.parent()).click(function(){
       // toggle the content
       $(this).toggleClass('twiddle-open');
       $(f_content).slideToggle();
    });
  });
};


$(function() {
  if( $('body').height() < 1000) {
    $('html').css('backgroundPosition', '0 700px');
  }
});
  
$(function() {
  $('.media_only .submit').hide();
  $('.media_only input:checkbox').change(function() { $(this).parent().submit() });
});

$(function() {
  $('.facet_limit').not(':has(h3)').hide();
});

$(function() {
  $('.blacklight-catalog-show .blacklight-dc_description_t .value').jTruncate({length: 500, moreText: " more", minTrail: 100});
  $('.blacklight-catalog-show .blacklight-topic_cv .value').jTruncate({length: 300, minTrail: 50, moreText: " more"});
  $('.blacklight-catalog-show .blacklight-tags .value').jTruncate({length: 150, minTrail: 50, moreText: " more"});
});

$(function() {
  $('.blacklight-collections-index .blacklight-collection').first().before($('<h2>Collections</h2>'));
  $('.blacklight-collections-index .blacklight-series').first().before($('<h2>Series</h2>'));
});
