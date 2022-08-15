open Cohttp_lwt_unix

let respond_string ~content_type ~status ~body ?headers =
  let headers = Cohttp.Header.add_opt headers "Content-Type" content_type in
  Server.respond_string ~headers ~status ~body
;;

let respond_file ~content_type ~fname ?headers =
  let headers = Cohttp.Header.add_opt headers "Content-Type" content_type in
  Server.respond_file ~headers ~fname
;;

let html =
  {|
<!DOCTYPE html>
<html lang="en">
    <head>
      <style>
.dropbtn {
  background-color: #3498DB;
  color: white;
  padding: 16px;
  font-size: 16px;
  border: none;
  cursor: pointer;
}

.dropbtn:hover, .dropbtn:focus {
  background-color: #2980B9;
}

.dropdown {
  position: relative;
  display: inline-block;
}

.dropdown-content {
  display: none;
  position: absolute;
  background-color: #f1f1f1;
  min-width: 160px;
  overflow: auto;
  box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2);
  z-index: 1;
}

.dropdown-content a {
  color: black;
  padding: 12px 16px;
  text-decoration: none;
  display: block;
}

.dropdown a:hover {background-color: #ddd;}

.show {display: block;}
      </style>

      <script src="jquery-1.8.3.min.js"></script>
      <script src="d3.min.js"></script>
      <script type="text/javascript" src="main.js"></script>
      <script type="text/javascript">
var T = tSNE;
var Y;

var data;

function updateEmbedding() {
  var Y = T.getSolution();
  svg.selectAll('.u')
    .data(data.labels)
    .attr("transform", function(d, i) { return "translate(" +
                                          ((Y[i][0]*20*ss + tx) + 400) + "," +
                                          ((Y[i][1]*20*ss + ty) + 300) + ")"; });
}

var svg;
function drawEmbedding() {
    $("#embed").empty();
    var div = d3.select("#embed");

    // get min and max in each column of Y
    var Y = T.Y;
    
    svg = div.append("svg") // svg is global
    .attr("width", 1140)
    .attr("height", 1140);

    var g = svg.selectAll(".b")
      .data(data.labels)
      .enter().append("g")
      .attr("class", "u");

    if (data["users"] !== undefined) {
    g.append("svg:image")
      .attr('x', 0)
      .attr('y', 2)
      .attr('width', 24)
      .attr('height', 24)
      .attr("xlink:href", function(d, i) { return data.users[i] })
    } else {
    cs = g.append("circle")
      .attr("cx", 0)
      .attr("cy", 0)
      .attr("r", 5)
      .attr('stroke-width', 1)
      .attr('stroke', 'black')
      .attr('fill', 'rgb(100,100,255)');
    }

    if (data.labels !== undefined) {
    g.append("text")
      .attr("text-anchor", "top")
      .attr("font-size", 12)
      .attr("fill", "#333")
      .text(function(d, i) { return data.labels[i]; });
    }

    var zoomListener = d3.behavior.zoom()
      .scaleExtent([0.1, 10])
      .center([0,0])
      .on("zoom", zoomHandler);
    zoomListener(svg);
}

var tx=0, ty=0;
var ss=1;
function zoomHandler() {
  tx = d3.event.translate[0];
  ty = d3.event.translate[1];
  ss = d3.event.scale;
}

function step() {
  for(var k=0;k<1;k++) {
    T.step(); // do a few steps
  }
  updateEmbedding();
}

var data_file = "states_conf.json"

$(window).load(function() {
  console.log("All loaded. Select a file");
});
function myFunction() {
  document.getElementById("myDropdown").classList.toggle("show");
}

function loadFile(data_file){
  myFunction();
  console.log("Called load file", data_file);
  $.getJSON(data_file, function( j ) {
    data = j;
    T.init(10,5,2);
    if(data_file.includes("states")) {
      T.initDataRaw(data.mat);
    } else {
      T.initDataDist(data.mat); // init embedding
    }
    T.initSolution();
    drawEmbedding(); // draw initial embedding

    //T.debugGrad();
    setInterval(step, 0);
    //step();

  });  
}
      </script>

    </head>
    <body>
      <h1>T-SNE Implementation</h1>
<div class="dropdown">
  <button onclick="myFunction()" class="dropbtn">SelectFile</button>
  <div id="myDropdown" class="dropdown-content">
    <a href="#home" onclick="loadFile('states.json')">states.json</a>
    <a href="#about" onclick="loadFile('states_conf.json')">states_conf.json</a>
    <a href="#contact" onclick="loadFile('coco.json')">coco.json</a>
  </div>
</div>
        <div id="embed"></div>
    </body>
</html>
|}
;;

let default_port = 8080

let server port =
  let callback _conn req _body =
    let uri = req |> Request.uri |> Uri.path in
    match uri with
    | "" | "/" | "/index.html" ->
      respond_string ~content_type:"text/html" ~status:`OK ~body:html ()
    | "/main.js" ->
      respond_string
        ~content_type:"application/javascript"
        ~status:`OK
        ~body:Embedded_files.main_dot_bc_dot_js
        ()
    | "/jquery-1.8.3.min.js" | "/d3.min.js" ->
      let path = String.concat "" [ "client/dist"; uri ] in
      respond_file ~content_type:"application/javascript" ~fname:path ()
    | "/coco.json" | "/states.json" | "/states_conf.json" ->
      let path = String.concat "" [ "client/dist"; uri ] in
      respond_file ~content_type:"application/json" ~fname:path ()
    | _ ->
      if Core.String.is_substring uri ~substring:".jpg"
      then (
        let path = Core.String.drop_prefix uri 1 in
        print_string path;
        respond_file ~content_type:"application/jpeg" ~fname:path ())
      else respond_string ~content_type:"text/html" ~status:`Not_found ~body:"" ()
  in
  Server.create ~mode:(`TCP (`Port port)) (Server.make ~callback ())
;;

let main ~port =
  Printf.printf "Running server at %d\n" port;
  flush stdout;
  Lwt_main.run @@ server port
;;

let () = main ~port:default_port
