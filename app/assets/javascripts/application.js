// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require_tree .

(function($) {
  $(document).ready(function(){
    $('.survey ul.contacts > li').click(function(){
      window.location = $(this).data('url');
    });
    $('a.prev-page').click(function(){
      parent.history.back();
      return false;
    });

    $('.carousel').carousel({
      interval: false
    })

    $('.report-progress form input[type=radio]').click(function(){
      $(this).closest("form").submit();
    });

    $('a.reverse-progress').click(function(){
      $('.carousel').carousel('prev');
    });

    $('a.screen').click(function(){
      progress = $('.progress > .bar');
      progress_text = $('.progress > .bar > .desc');
      id = $(this).data('screen-id');
      console.log(id);
      switch(id)
      {
        case 'home':
          $('.carousel').carousel(0);
          set_progress('25%','Onwards Ho!');
          break;
        case 'scr_6a':
          $('.carousel').carousel(1);
          set_progress('50%','Giddy Up!');
          break;
        case 'scr_6b':
          $('.carousel').carousel(2);
          set_progress('75%','The Final Stretch');
          break;
        case 'scr_6c':
          $('.carousel').carousel(2);
          set_progress('75%','The Final Stretch');
          break;
        case 'scr_8a':
          $('.carousel').carousel(3);
          set_progress('100%','Completed');
          break;
        case 'scr_8b':
          $('.carousel').carousel(4);
          set_progress('90%','A Tad More');
          break;
        case 'scr_10a':
          $('.carousel').carousel(3);
          set_progress('100%','Completed');
          break;
        case 'scr_10b':
          $('.carousel').carousel(3);
          set_progress('100%','Completed');
          break;
      };

      function set_progress(percentage,msg) {
        progress = $('.progress > .bar');
        progress_text = $('.progress > .bar > .desc');
        progress.width(percentage);
        progress_text.text(msg);
      };
    });

  })
})(jQuery);