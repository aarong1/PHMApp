$(document).ready(function() {
  // Function to set draggable attribute on all canvas elements
  function makeCanvasDraggable() {
    $("canvas").attr("draggable", true);
    $("table").attr("draggable", true);

  };

  // Initial call to make canvases draggable
  makeCanvasDraggable();
  
  console.log("draggable fn called");

  // Listen for Bootstrap tab change event
  $("a[data-toggle=tab]").on("shown.bs.tab", function() {
    makeCanvasDraggable();
    
    // Function to setup each canvas
    function setupCanvas(canvas) {
        // Add dragstart event
        canvas.addEventListener("dragstart", function(event){
            const dataUrl = canvas.toDataURL("image/png");
            event.dataTransfer.setData("text/plain", dataUrl);
            console.log(event.dataTransfer.getData("text/plain"));
        });
    }

    // Get all canvas elements and setup them
    const canvases = document.getElementsByTagName("canvas");
    Array.from(canvases).forEach(setupCanvas);

    // Add dragover event to allow dropping
    document.getElementById("editor").addEventListener("dragover", function(event){
        event.preventDefault();
    });

    // Add drop event to insert image into Quill
    document.getElementById("editor").addEventListener("drop", function(event){
        event.preventDefault();
        const dataUrl = event.dataTransfer.getData("text/plain");
        console.log(dataUrl);
        const range = quill.getSelection();
        quill.insertEmbed(range.index, 
        "image", dataUrl);
    });
    
  });
});