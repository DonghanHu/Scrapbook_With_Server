
const jsonFilePath = "/Users/donghanhu/Documents/ScrapbookServer/Scrapbook.json";
var jsonInformation = [];

// two hard-code josn information

console.log("this is the begining of this javascript file")

// for each recording, extract information in an array
var pinterestLayout = (function ($) {
    // default setting
    var $board = null;
    var $columns = null;
    var pins = null;
    var colWidth = null;
    var colMargin = 10;
    var containerPadding = 10;

    getWidth();

    function getWidth(){
        var screenwidth = $(window).width();
        colWidth = (screenwidth - 50 ) / 4;
        console.log("width value is: ")
        console.log(colWidth);
    }

    // click search button

    var recordings = null;
    var searchedCollections = null;

    function displayImage(pid, psrc) {
        console.log("Open a page to show further information.");

//       // method 1
//       var img = document.getElementById(pid);
//       img.src = psrc;
//       img.style.display = 'block';
//
//       // method 2
//       var largeImage = document.getElementById(pid);
//       largeImage.style.display = 'block';
//       var url=largeImage.getAttribute('src');
//       window.open(url,'Image');
//
//       // method 3:
//       window.location.href = 'http://' + psrc;

    }

  

    function init() {
        console.log("run init funtion");
        $container = $('.container');
        $board = $('#board');
        $.getJSON(jsonFilePath, function (json) {
            console.log("the whole json file: ");
            console.log(json); // this will show the info it in the console
            console.log("the count of json file is: ");
            console.log(json.length)

            // reverse the json array, the topest one is the latest one
            pins = json.reverse()

            // figure this out later
            $(window).resize(drawBoard).trigger('resize');

        });

    }

    function drawBoard() {
        // check whether the current collection is empty
        if (!pins.length) {
            alert("Sorry, but there is no collections currently!");
            return;
        }
        // get the width of current window
        var screenWidth = $(window).width();
        // set the number of columns, which is 4, default
        numColumns = Math.floor(screenWidth / (colWidth + colMargin));
        // set the container's width
        // four columns with 5 margin paddings
        containerWidth = (numColumns * (colWidth + colMargin)) + containerPadding;
        // set the container width for the "container"
        $container.css({ width: containerWidth });

        // Layout Columns
        $board.html('');
        for (i = 0; i < numColumns; i++) {
            // draw column layout
            $board.append('<div class="column" id="column' + i + '"></div>');

        }

        $columns = $('.column');
        // set coulumn's width
        $columns.css({width: colWidth });
        var eachColumsWidth = $(".column").width();

        // Layout Pins
        var startindex = 0;
        var pinsLen = pins.length;

        $(pins).each(function (recordingIndex, pin) {

            var pinWidth = $(".pin").width();

            startindex++;

            pin = pinTemplate(pin, recordingIndex);

            column = shortestColumn()
            column.append(pin);

        });
                                
    }

    // get the current shorest column index
    function shortestColumn() {
        $columns.sort(function (a, b) {
            return $(a).height() - $(b).height();
        });
        // if two columns are the same, return the first one
        return $columns.first();
      }


  /* 渲染模板 */
    function pinTemplate(singleRecording, recordingIndex) {

        // console.log("Each pin information:")
        // console.log(options)

        var html = '';

        // extract informaiton from options seperatly

        var allApplicationInformationArray = singleRecording.ApplicationInformation
        var capturedScreenshotInformationArray = singleRecording.CaptureRegion
        var screenshotPath = singleRecording.ImagePath
        var screenshotDescription = singleRecording.ScreenshotText
        var screenshotTitle = singleRecording.ScreenshotTitle
        var screenshotTimeStamp = singleRecording.TimeStamp

        // print each information seperately
        console.log(typeof(allApplicationInformationArray))
        // object
        console.log(allApplicationInformationArray)
        // object
        console.log(typeof(capturedScreenshotInformationArray))
        console.log(capturedScreenshotInformationArray)
        console.log(screenshotPath)
        // /Users/donghanhu/Documents/ScrapbookServer/Screenshot-09.30,13:20:52.jpg
        console.log(screenshotDescription)
        console.log(screenshotTitle)
        console.log(screenshotTimeStamp)


        // set id for each screenshot in html page
        var pinId = "pin_" + recordingIndex;

        var pinSrc = screenshotPath;

        // code here to create href for each screenshot to click

        var temphref = "tempString"
        html += `
        <a href="${temphref}" class="pin" id="${pinId}" style="width:${colWidth-20}px">
            <h3>${screenshotTitle ? screenshotTitle : "Empty title here."}</h3><img src="${screenshotPath}" onclick="displayImage(pinId, pinSrc);"></img>
            
            <small>${screenshotDescription? screenshotDescription : "Empty description here."}<small>
            </br>
            </small>${screenshotTimeStamp ? screenshotTimeStamp : "Empty time stamp here."}</small>
        </a>
        `
        
        return html;
        

    }

    init();

}(jQuery));






