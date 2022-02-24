// const {ObjectId} = require('mongodb');
let express = require("express");
var bodyParser   = require('body-parser');
let fs = require('fs')
let app = express();

let dbo = null;
let VERBOSE = true;

app.use(express.urlencoded({ extended: true }))
app.use(express.json());
app.use(express.static(__dirname + '/public'));

//make way for some custom css, js and images
app.use('/css', express.static(__dirname + '/public	/css'));
app.use('/js', express.static(__dirname + '/public/js'));
app.use('/images', express.static(__dirname + '/public/data'));

let server = app.listen(8080, function(){
    let port = server.address().port;
    if(VERBOSE)console.log("Scrapbook Server stated at http://localhost:%s", port);
});


// create a mongo database for scrapbook
let MongoClient = require('mongodb').MongoClient;

// require ID
var ObjectID = require('mongodb').ObjectID; 

// child_process
var cp = require("child_process");

// database local url
let url = "mongodb://localhost:27017/Scrapbook";

MongoClient.connect(url, { useUnifiedTopology: true }, function(err, db) {
  if (err) throw err;

  // set collection Name as: Scrapbook
  dbo = db.db("Scrapbook");
  if(VERBOSE)console.log("Database created!");
  
// recording 

  // if collection does not exist, then create it
  dbo.listCollections({name: "recordings"}).next(function(err, collinfo) {
    if (collinfo) {
      console.log("Collection recording exists");
    } else {
      // create outlets: recordings
      dbo.createCollection("recordings", function(err, res) {
        if (err) throw err;
        if(VERBOSE)console.log("Collection recording created!");
      });
    }
  })

});

// function delete saved temp task data
// step 1: remove the screenshot
// step 2: optional: clear the temp json file
app.post('/deleteTempScreenshot', function (req, res) {
  if(VERBOSE)console.log("/delete temp screenshot request");

  // let imageURL = req.body._imageurl;
  // console.log(imageURL);
  // console.log(__dirname);

  let imageURL = __dirname + "/public" + req.body._imageurl;
  console.log(imageURL);
  // /Users/donghanhu/Documents/ScrapbookServerFolder
  // /Users/donghanhu/Documents/ScrapbookServerFolder/public/Data/Screenshot-2021.12.06,16-08-36.jpg
  fs.stat(imageURL, function (err, stats) {
    console.log(stats);//here we got all information of file in stats variable
 
    if (err) {
      writeBadRequestResponse(res, "delete temp recording image: recording's url is not defined." + req.body);
      return;
    }
 
    fs.unlink(imageURL,function(err){
         if(err) return console.log(err);
         writeOKResponse(res, "delete temp recording image: screenshot has been deleted Successfully", {__imageurl: req.body._imageurl});
         console.log('file deleted successfully');
    });  
 });

  // // clear the temp json file by replacing with an empty array
  // let result = [];
  // try {
  //   fs.writeFile('/Data/tempScreenshotData.json', JSON.stringify(result))
  // } catch(err) {
  //     console.error(err)
  // }
});

// 
app.post('/logFunc', function(req, res){
  if(VERBOSE)console.log("/logFunc");
  let timeStamp = req.body.timeStamp;
  let actionName = req.body.actionName;
  let logInfor = req.body;
  // database, collectionName, insertInfor
  insertLog(dbo, "recordings", logInfor, function(data){
    writeOKResponse(res, "new log: saved", data.timeStamp);
  });
});

let insertLog = function(db, collectionN, data, callback){
  db.collection(collectionN).insertOne(data, function(err, result) {
    if (VERBOSE)console.log("insert log: " + data._timeStamp);
    if (callback)callback(data);
  });
}

// save temp recording data into database
// do nothing with the screenshot
app.post('/saveTempScreenshot', function (req, res) {
    if(VERBOSE)console.log("/save temp screenshot request");

    let screenshotInfor = req.body;
    console.log(screenshotInfor);

    // set additional information
    screenshotInfor.createdDate= new Date(),
    screenshotInfor.deleted = false;

    // insert recording information to the database
    insertScreenshot(dbo, "Scrapbook", screenshotInfor, function(data){
      writeOKResponse(res, "new screenshot: saved Successfully", {_imageurl: data._imageurl});
    })
});

let insertScreenshot = function(db, databaseName, data, callback){
  db.collection(databaseName).insertOne(data, function(err, result) {
    if (VERBOSE)console.log("insertDocument: Inserted a document into the " + databaseName + " collection. : " + data._imageurl);
    if (callback)callback(data);
  })
};

let updateOneDocument = function(db, collectionName, query, newvalues, callback) {
  if(VERBOSE)console.log("updateOneDocument: query:" + JSON.stringify(query));
  if(VERBOSE)console.log("updateOneDocument: newValue:" + JSON.stringify(newvalues));
  db.collection(collectionName).updateOne(query,{ $set: newvalues }, function(err, res) {
    if (err) {
      throw err;
      if(callback)callback(err);
    }
    if(VERBOSE)console.log("updateOneDocument: Updated a document in "+collectionName+" collection. ");

    if(callback)callback();
  });
};

app.get('/fetchrecordings', function (req, res) {
  if(VERBOSE)console.log("/fetchercording request");

  let list = retreiveDocsList(
    dbo
    , {deleted:false}
  );
  console.log("list data in database");
  // console.log(list.length);
  console.log(list);

  list.toArray(function(err, docs){
    if(err){
      writeBadRequestResponse(res, "fetchrecordings: Error in fetching recordings data: " + err);
    }
    else{
      writeOKResponse(res, "fetchrecordings: Succesfully Fetched recordings data ", docs);
    }
  });
});

app.post('/searchKeyWord', function (req, res) {
  if(VERBOSE) console.log("/searchkeyword request");

  var targetString = req.body.keyWord;
  console.log(req.body);
  console.log("this is the searching key word:");
  console.log(targetString);

  // dbo.collection('Scrapbook').createIndex({ title: "text", fullplot: "text" });
  // keyWord
  // const query = { $text: { $search: "trek" } };

  const query = { $search: targetString };
  const fields = {
    id: 1
  };

  // cursor = dbo.collection('Scrapbook').find(query).project(fields);

  // console.log("this is the first searched list(cursor): ");
  // console.log(cursor);
  // dbo.collection('Scrapbook').getIndexes();
  // code here, query in an array
  dbo.collection('Scrapbook').createIndex({ScreenshotPictureName:"text",ScreenshotText:"text", ScreenshotTitle:"text", 
  "ApplicationInformation.ApplicationName":"text", "ApplicationInformation.FirstMetaData":"text", "ApplicationInformation.SecondMetaData":"text"});
  console.log(targetString);

  // /.*son.*/
  let str = "/.*" + targetString + ".*/"
  console.log(str);

  let temp = "/4/"
  test = dbo.collection('Scrapbook').find({$text:{$search: str, $caseSensitive: false}});

  // test = dbo.collection('Scrapbook').find({'ScreenshotText': {'$regex': str}});

  console.log("type of test");
  console.log(typeof test);

  console.log("this is the second searched list(test): ");
  // console.log(test);


  
  test.toArray(function(err, docs){
      if(err){
        writeBadRequestResponse(res, "searchKeyWord: Error in fetching data with key word: " + err);
      }
      else{
        
        writeOKResponse(res, "searchKeyWord: Succesfully Fetched recordings data with key word ", docs);
      }
    });

});

// function to print success information
//https://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
let writeOKResponse = function(res, message, data){
  let obj = {
    status: "OK",
    message: message,
    data: data
  };
  if(VERBOSE)console.log("writeOKResponse:" + message);

  res.writeHead(200, {'Content-type': 'application/json'});
  res.end(JSON.stringify(obj));
}

let writeBadRequestResponse = function(res, message){
  if(VERBOSE)console.log("writeBadRequestResponse:" + message);
  res.writeHead(400, {'Content-type': 'text/plain'});
  res.end(message);
}

let retreiveDocsList = function(db, query, fields, sort ){
  try {
    console.log("this is cursor function: ");
    cursor = db.collection('Scrapbook').find(query).sort(sort).project(fields);
    console.log(typeof cursor);
    console.log(cursor);
  } catch (err) {
    if(VERBOSE)console.log("retreiveAllDocsList: retreiveAllDocsList Error\n" + err);
  }
  return cursor;
};

let searchDocsList = function(db, query, fields, sort) {
  console.log("this is query: ");
  console.log(query);
  console.log("this is fields: ");
  console.log(fields);
  console.log("this is sort: ");
  console.log(sort);

  try {
    console.log("in searchDocList function");
    cursor = db.collection('Scrapbook').find(query).sort(sort).project(fields);
    // curosr = db.collection.find({searchkey : {$regex: new RegExp('.*' + search.toLowerCase()+'.*', 'i')},searchkey : {$regex: new RegExp('.*' + search.toUpperCase()+'.*','i')},is_active:true},function(error,fetchSearch){ console.log(fetchSearch); });
    // console.log(fetchSearch);
    // cursor = db.collection('Scrapbook').find(query).sort(sort).project(fields);
    console.log("this is the cursor list");
    console.log(cursor);
  }catch(err) {
    if(VERBOSE)console.log("search key word in DocsList: searchDocsList Error\n" + err);
  }
  return cursor;
};

app.post('/fetchRecordingInformation', function(req, res){
  if(VERBOSE)console.log("/fetchRecordingInformation request");
  console.log(req.body);
  var targetID = req.body.screenshotID;
  console.log("this is the searching ID:");
  console.log(targetID);


  // db.collection('students').find({"_id": new ObjectID(req.body._id)})
  cursor = dbo.collection('Scrapbook').find({"_id": new ObjectID(targetID)});
  cursor.toArray(function(err, docs){
    if(err){
      writeBadRequestResponse(res, "searchID: Error in fetching data through ID: " + err);
    }
    else{
      
      writeOKResponse(res, "searchID: Succesfully Fetched recording through ID", docs);
    }
  });

});

// delete recording in the database through id
app.post('/deleteRecordingDetailedView', function(req, res){
  if(VERBOSE) console.log("/deleteRecordingDetailedView request");
  console.log(req.body.screenshotID);
  var targetID = req.body.screenshotID;
  dbo.collection('Scrapbook').deleteOne({_id: new ObjectID(targetID)});
  
  if (err) throw err;

});

// delete screenshot in the local folder
app.post('/deleteScreenshotDetailedView', function(req, res){
  if(VERBOSE) console.log("/deleteScreenshotDetailedView request");
  console.log(req.body.screnenshotName);
  var targetImage = req.body.screnenshotName;
  // target local url
  let imageURL = __dirname + "/public" + targetImage;
  console.log(imageURL);

  fs.stat(imageURL, function (err, stats) {
    console.log(stats);//here we got all information of file in stats variable
 
    if (err) {
      writeBadRequestResponse(res, "delete recording image detailed view: recording's url is not defined." + req.body.screnenshotName);
      return;
    }
 
    fs.unlink(imageURL,function(err){
         if(err) return console.log(err);
         writeOKResponse(res, "delete recording image detailed view: screenshot has been deleted Successfully", {screnenshotName: req.body.screnenshotName});
         console.log('file deleted successfully');
    });
  });  
});

app.post('/openApplication', function(req, res){
  //_name: appName, _cate: appCate, _first: appFirstInfor, _second: appSecondInfor
  if(VERBOSE) console.log("/openApplication request");
  var appName = req.body._name;
  var appCate = req.body._cate;
  var appFirstInfor = req.body._first;
  var appSecondInfor = req.body._second;
  var setValue = -1;
  // identify the category of this application
  console.log(appCate);
  var shellComand = "open -a ";
  var doubleQuotes = "\"";
  var singleQuote = "\'";

  // google chrome

  // // worked for safari
  // var testCommand = "open -a \"Safari\" 'https://www.apple.com/'"
  // // workded for finder
  // var testCommand = "open -a \"Finder\" '/Users/donghanhu/Downloads/submissions (3)'"
  // Microsoft Word worked
  // var testCommand = "open -a \"Microsoft Word\" '/Users/donghanhu/Downloads/2:9 IRB-19-189-protocol.docx'"
  // preview worked
  // var testCommand = "open -a \"Preview\" '/Users/donghanhu/Downloads/CS_5560_Homework3_Solution.pdf'"
  // adobe reader worked
  // var testCommand = "open -a \"Acrobat Reader\" '/Users/donghanhu/Downloads/CS_5560_Homework3_Solution.pdf'"
  // textedit worked
  // var testCommand = "open -a \"TextEdit\" '/Users/donghanhu/Downloads/Untitled.rtf'"
  // pages worked
  // var testCommand = "open -a \"Keynote\" '/Users/donghanhu/Downloads/test1.key'"


  // console.log(testCommand);
  // cp.exec(testCommand, function(error,stdout,stderr){
  //   console.log(error);
  //   console.log(stdout);
  //   console.log(stderr);
  // });

  // worked for google chrome
  // check appname and first information
  
  if (appName != null && appFirstInfor != "the result is empty"){
    shellComand = shellComand + doubleQuotes + appName + doubleQuotes +  " '" + appFirstInfor + "'";
    console.log(shellComand);

    cp.exec(shellComand, function(error,stdout,stderr){
      console.log(error);
      console.log(stdout);
      console.log(stderr);
    });
  }
  else if(appName != null && appFirstInfor == "the result is empty"){
    shellComand = shellComand + doubleQuotes + appName + doubleQuotes;
    console.log(shellComand);

    cp.exec(shellComand, function(error,stdout,stderr){
      console.log(error);
      console.log(stdout);
      console.log(stderr);
    });
  }
  else{
    console.log("applicaiton name is null and first information is null!");
  }
  

  //childProc.exec('open -a "Google Chrome" http://your_url', callback);


});

app.post('/updateRecordingDetailedView', function(req, res){
  if(VERBOSE) console.log("/updateRecordingDetailedView request");
  console.log(req.body.changedData);
  var screenshotInformation = req.body.changedData;
  // console.log(req.body);
  // console.log(screenshotInformation);
  console.log(screenshotInformation.ScreenshotText);
  console.log(screenshotInformation.ScreenshotTit);

  var screenshotID = req.body.screenshotID;
  console.log(screenshotID);

  dbo.collection('Scrapbook').updateOne({ _id: new ObjectID(screenshotID)}, 
  { $set: {"ScreenshotTitle": screenshotInformation.ScreenshotTit,
           "ScreenshotText": screenshotInformation.ScreenshotText}}, 
  function(err, result){
    console.log(result);
    console.log(err);

  }); 
});

// app.get('/fetchtasks', function (req, res) {
//   if(VERBOSE)console.log("/fetchtasks request");
//   let list = retreiveAllDocsList(
//     dbo
//     , {deleted:false}
//     , { _id: 1, title: 1 , note: 1, completed:1, completeDate: 1, dueDate:1 }
//     , {createdDate: 1}
//   );
//   list.toArray(function(err, docs){
//     if(err){
//       writeBadRequestResponse(res, "fetchtasks: Error in fetching data: " + err);
//     }
//     else{
//       writeOKResponse(res, "fetchtasks: Succesfully Fetched Tasks Data ", docs);
//     }
//   });
// });


// app.post('/deletetask', function (req, res) {
//   if(VERBOSE)console.log("/deletetask request");

//   let task_id = req.body._id;
//   if(task_id == null){
//     writeBadRequestResponse(res, "deletetask: task _id not defined." + req.body);
//     return;
//   }

//   updateOneDocument(dbo, "tasks",   {_id:ObjectId(task_id)}, {deleted:true}, function(err){
//     if(err){
//       writeBadRequestResponse(res, "deletetask: Delete Document Failed" + err);
//       return;
//     }
//     writeOKResponse(res, "deletetask: Task deleted Successfully", {_id: task_id});
//   });
// });

// app.post('/updatetask', function (req, res) {
//   if(VERBOSE)console.log("/updatetask");

//   let task_id  = req.body._id; // provide the _id
//   let task_data  = req.body.data;

//   if (task_id == undefined){
//     writeBadRequestResponse(res, "updatetask: _id not defined.");
//     return;
//   }

//   if (task_data == undefined){
//     writeBadRequestResponse(res, "updatetask: data for id("+task_id+") not defined.");
//     return;
//   }

//   for (let j=0; j< Object.keys(task_data).length; j++){
//     if (!["title", "note", "dueDate", "completed", "completeDate"].includes(Object.keys(task_data)[j])){
//       writeBadRequestResponse(res, "updatetask: unknown update field("+Object.keys(task_data)[j]+").");
//       return;
//     }
//   }

//   if (task_data.title && typeof(task_data.title) != "string"){
//     writeBadRequestResponse(res, "updatetask: title needs to be string("+task_data.title+").");
//     return;
//   }

//   if (task_data.note && typeof(task_data.note) != "string"){
//     writeBadRequestResponse(res, "updatetask: note needs to be string("+task_data.note+").");
//     return;
//   }

//   if (task_data.completed && task_data.completed != "true" && task_data.completed != "false" ){
//     writeBadRequestResponse(res, "updatetask: completed needs to be boolean("+task_data.completed+").");
//     return;
//   }

//   if (task_data.completed){
//     task_data.completed = (task_data.completed == "true");
//   }

//   if(task_data.dueDate && typeof(task_data.dueDate) != "string"){
//     writeBadRequestResponse(res, "updatetask: Due date needs to be string:" + task_data.dueDate);
//     return;
//   }

//   if(task_data.dueDate){
//     if(task_data.dueDate != '' && isNaN(Date.parse(task_data.dueDate)))
//     {
//       writeBadRequestResponse(res, "updatetask: Due date ill defined:" + Date.parse(task_data.dueDate));
//       return;
//     }
//   }

//   if(task_data.completeDate && typeof(task_data.completeDate) != "string"){
//     writeBadRequestResponse(res, "updatetask: Complete date needs to be string:" + task_data.completeDate);
//     return;
//   }

//   if(task_data.completeDate && isNaN(Date.parse(task_data.completeDate))){
//     writeBadRequestResponse(res, "updatetask: Complete date ill defined:" + Date.parse(task_data.completeDate));
//     return;
//   }

//   updateOneDocument(dbo, "tasks",   {_id:ObjectId(task_id)}, task_data, function(err){
//     if(err){
//         writeBadRequestResponse(res, "updatetask: Update Document Failed" + err);
//         return;
//     }
//     writeOKResponse(res, "updatetask: Updated Successfully("+task_id+")", {_id: task_id});
//   });
// });

// app.post('/newtask', function (req, res) {
//   let task = req.body;

//   if(typeof(task.title)!="string"){
//     writeBadRequestResponse(res, "newtask: No title is defined.");
//     return;
//   }

//   if(task.dueDate != '' && isNaN(Date.parse(task.dueDate))){
//     writeBadRequestResponse(res, "newtask: Due date ill defined:" + Date.parse(task.dueDate));
//     return;
//   }

//   if(typeof(task.note)!="string"){
//     writeBadRequestResponse(res, "newtask: No due date is defined.");
//     return;
//   }

//   // default data.
//   task.completed = false,
//   task.completeDate = null,
//   task.createdDate= new Date(),
//   task.deleted=false;

//   insertDocument(dbo, "tasks", task, function(data){
//     writeOKResponse(res, "newtask: Created Successfully", {_id: data._id});
//   });

// });
