var WysiwygAreaEdit = {
  init: function() {
    TSEditor.registerOnEdit('wysiwyg-area', WysiwygAreaEdit.instantiate);
  },
  initMce: function() {
    var authToken = document.forms[0].authenticity_token.value;
    tinyMCE.init({
      mode: "none",
      theme_advanced_toolbar_location: "top",
      plugins: "safari,spellchecker,advhr,tsimage,advlink,emotions,iespell,inlinepopups,preview,media,searchreplace,contextmenu,paste,fullscreen,visualchars,nonbreaking,xhtmlxtras",
      theme_advanced_blockformats: "p,h1,h2,h3,h4,blockquote",
    	theme_advanced_statusbar_location : "bottom",
      theme_advanced_buttons1: "undo,redo,removeformat,|,formatselect,fontsizeselect,|,bold,italic,underline,|,justifyleft,justifycenter,justifyright,|,outdent,indent,bullist,numlist,hr,backcolor,|,link,unlink,charmap,image,media,iespell,|,search,replace,|,code,fullscreen",
      theme: "advanced",
      theme_advanced_buttons2: "",
      theme_advanced_resizing: true,
      theme_advanced_buttons3: "",
      theme_advanced_toolbar_align: "left",
      gecko_spellcheck: true,
      editor_selector: "wysiwyg-area-tinymce",
      skin: "o2k7",
  		skin_variant: "silver",
      theme_advanced_resize_horizontal: false,
      cdn_host: 'tinymce1.thrivesmart.net',
      authenticity_token: authToken
    });
  },
  instantiate: function(el) {
    if (!WysiwygAreaEdit.inittedMCE) { WysiwygAreaEdit.inittedMCE = true; WysiwygAreaEdit.initMce(); }
    tinyMCE.execCommand('mceAddControl', true, el.getElementsByTagName('textarea')[0].id);
  }
}
WysiwygAreaEdit.init();