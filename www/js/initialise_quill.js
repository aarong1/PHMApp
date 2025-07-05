$(document).ready(function() {
  
  console.log('quill init function called');
  
 // Quill.register("modules/imageResize", ImageResize);

  
  const toolbarOptions = [
  ['bold', 'italic', 'underline', 'strike'],        // toggled buttons
  ['blockquote', 'code-block'],
  ['link', 'image', 'video', 'formula'],

  [{ 'header': 1 }, { 'header': 2 }],               // custom button values
  [{ 'list': 'ordered'}, { 'list': 'bullet' }, { 'list': 'check' }],
  [{ 'script': 'sub'}, { 'script': 'super' }],      // superscript/subscript
  [{ 'indent': '-1'}, { 'indent': '+1' }],          // outdent/indent
  [{ 'direction': 'rtl' }],                         // text direction

  [{ 'size': ['small', false, 'large', 'huge'] }],  // custom dropdown
  [{ 'header': [1, 2, 3, 4, 5, 6, false] }],

  [{ 'color': [] }, { 'background': [] }],          // dropdown with defaults from theme
  [{ 'font': [] }],
  [{ 'align': [] }],

  ['clean']                                         // remove formatting button
];

const quill = new Quill('#editor', {
  modules: {
    toolbar: toolbarOptions,
 
        // ...
        imageResize: {
          displaySize: true
        },
    
  },
  theme: 'snow'
});

window.quill = quill;


if (localStorage.getItem("delta") === null) {
  
} else {
  
const blob = localStorage.getItem("delta");;
const delta = JSON.parse(localStorage.getItem('delta'));
const content = quill.setContents(delta);
}

});