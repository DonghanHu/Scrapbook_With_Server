
const jsonFilePath = "Scrapbook/Scrapbook.json";
var jsonInformation = [];

// two hard-code josn information

console.log("this is the begining of this work")

// for each recording, extract information in an array
var pinterestLayout = (function ($) {
    // default setting
    var $board = null;
    var $columns = null;
    var pins = null;
    var colWidth = 170;
    var colMargin = 10;
    var containerPadding = 10;

    // var colWidth = (window.innerWidth - 50) / 4;
    // var colWidth = $(window).width();

    getWidth();

    function getWidth(){
        var width4 = $(window).width();
        colWidth = (width4 - 50 )/ 4;
        console.log("width value is: ")
        console.log(colWidth);
    }



    // click search button

    var recordings = null;
    var searchedCollections = null;


}(jQuery));






