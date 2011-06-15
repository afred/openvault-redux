// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
//

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
  $('.facet_limit').not(':has(h3)').hide();
});

$(function() {
  $('.blacklight-catalog-show .blacklight-dc_description_t .value').jTruncate({length: 500, moreText: " more", minTrail: 100});
  $('.blacklight-catalog-show .blacklight-topic_cv .value').jTruncate({length: 300, minTrail: 50, moreText: " more"});
  $('.blacklight-catalog-show .blacklight-tags .value').jTruncate({length: 150, minTrail: 50, moreText: " more"});
});
