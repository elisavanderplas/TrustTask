    export function stimdeviset(type,numtrials)

    {

        //CODE TO SHUFFLE ARRAY
        function shuffle(array)
        {		
        var currentIndex = array.length, temporaryValue, randomIndex;

        // While there remain elements to shuffle...
        while (0 !== currentIndex) {

        // Pick a remaining element...
        randomIndex = Math.floor(Math.random() * currentIndex);
        currentIndex -= 1;

        // And swap it with the current element.
        temporaryValue = array[currentIndex];
        array[currentIndex] = array[randomIndex];
        array[randomIndex] = temporaryValue;
        }

        return array;
        }


        //CODE TO REPLICATE ARRAY
        function repeatArray(arr, count) {

        var ln = arr.length;
        var b = [];

        for(i=0; i<count; i++) {

        b.push(arr[i%ln]);

        }

        return b;

        }
        
        function fillArray(value, len) 
        {
            var arr = [];
            for(var t = 0; t < value.length; t++)
            {
                for (var i = 0; i < len; i++) 
                {
                arr.push(value[t]);
                    
                }
                
            }
            return arr;
        }
        
    if (type == 'prac')

    {
            
        //the stim position
        pracstimpos= fillArray([1,2], (numtrials/2));
        pracpos = shuffle(pracstimpos);

                
            
    return pracpos;

    }

    else if (type == 'trial')

    {

    stimpos1= fillArray([1,2], (numtrials/2));

    //finally shuffle all these arrays horizontally, but not vertically (i.e. not to mess up the association between conf and acc)
    len = stimpos1.length; //length (i.e. number of trials)
    perm = shuffle(Array.from({length: len}, (_, index) => index));//get shuffled order of array 0:ntrials

    stimpos2 = []
        for (var j = 0; j < len; j++) {
            stimpos2[j] = stimpos1[perm[j]]
        }
    return stimpos1; 
    return stimpos2;
    return perm; 



    }

    }