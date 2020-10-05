    //Function to draw stimulus

    export function draw_stimulus(canvasID,numDots) 
    {
    var stimCanvas = document.getElementById(canvasID);
    var stimContext = stimCanvas.getContext("2d");
    stimContext.clearRect(0,0, stimCanvas.width, stimCanvas.height);

    //create black stimulus box
    var squareWidth = 250;
    var sqystartpoint= (stimCanvas.height - squareWidth)/2; //145 (h)
    var sqxstartpoint= (stimCanvas.width - squareWidth)/2; //75 (w)

    function createbox() 
    {
    stimContext.fillStyle = "#000000 "; // grey inner square#C0C0C0
    stimContext.fillRect(sqxstartpoint,  sqystartpoint, squareWidth, squareWidth);// Fill black square (stimulus background)
    }
    createbox();
        

    //specification 	
        var cellSize = 10;
        
        
        function randperm(maxValue){
    // first generate number sequence
    var permArray = new Array(maxValue);
    for(var i = 0 ; i < maxValue; i++){
        permArray[i] = i;
    }
    // draw out of the number sequence
    for (var b = (maxValue - 1); b >= 0; --b){
        var randPos = Math.round(b * Math.random());
        var tmpStore = permArray[b];
        permArray[b] = permArray[randPos];
        permArray[randPos] = tmpStore;
    }
    return permArray;
    }


    //vector of random 1s and 0s

    var dotindex = randperm(625); //vector of 0 to 649
    var dotmatrix = [];

    //j should be always 0 because its the index and not the value of the array
    //eg if j = 1, and value is negative, then it is a 1 (white) (plus more dots). so if add neg number for numDots1, essentially its adding dots.

    // if adding numDots, then dotindex[j] < 340, is 1 (which is coloured), so add more dots   

    for (var j = 0; j<625; j++) {   
    if (dotindex[j] < 313 + numDots)

    {dotmatrix[j] = 1;}
    else
    {dotmatrix[j] = 0;}
    }


    //the grid
        function createdots() {

        
        var k =0;

        for (var x = sqxstartpoint ; x < sqxstartpoint+squareWidth; x += cellSize )  {
    for (var y = sqystartpoint ; y < sqystartpoint+squareWidth; y += cellSize ) {
        
    stimContext.beginPath();
    stimContext.arc(x + (cellSize/2) , y +(cellSize/2), 2, 0, 2 * Math.PI);

        if (dotmatrix[k] === 1) 
    { stimContext.fillStyle="#FFFFFF";
    stimContext.fill();
    k++
        }
        else 
        {	 
    stimContext.fillStyle="#000000";
    stimContext.fill();
    k++
        }
    }}

        }

        

        createdots();
        


    var string4stimulus = stimCanvas.toDataURL();
    stimContext.clearRect(0, 0, stimCanvas.width, stimCanvas.height);

    return string4stimulus;

    }