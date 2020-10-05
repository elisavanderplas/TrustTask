export function advdeviset(type, numtrials, stimpos1, correct_data, confidence_data, perm)
//gets as input:
//type = whether we're creating advisers for the practice trials ('prac) or for real trials ('trial')
//stimpos1 = unpermutated 1/2 of length 'numTrials', which should be permutated according to 'perm' a shuffled array of 1:numtrials
//correct_data = all confidence-task associated accuracy levels (1=correct, 0=error)
//confidence_data = all unsigned confidence levels from the confidence task (1=not confident to 4=very confidence)

//returns
//stimpos2 = permutated stimpos1 as a function of order "perm"
//advpos2 = adviser type (1 = adviser 1, 2 = adviser 2)
//advconf2 = unsigned confidence of adviser, of length 1:numtrials w. adviser type = corresponding advpos2[n]

{
		//CODE TO SHUFFLE ARRAY
		function shuffle(array)
		{		
		    var currentIndex = array.length, temporaryValue, randomIndex;
		    // While there remain elements to shuffle...
            while (0 !== currentIndex) 
            {
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
		function repeatArray(arr, count) 
		{
		    var ln = arr.length;
		    var b = [];

		    for(i=0; i<count; i++) 
		    {

		        b.push(arr[i%ln])
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

if (type == 'prac')// if we're dealing with practice trials, the order doesn't really matter
	
	{	
		advpos2_prac = fillArray([3,3,3,3],(numtrials/4));//always dealing with the practice adviser '3'
        advacc_prac = fillArray([1,1,0,1],(numtrials/4)); //making accuracy advisers in practice session 75%
        advconf_prac = fillArray([7,4,4,7],(numtrials/4));//practice confidence 
        pracpos = fillArray([1,2,1,2], (numtrials/4)); //objectively correct direction during practice trials    
		return advpos2_prac; 
        return advconf_prac; 
        return pracpos;	    
	}
else if (type == 'trial')
    {      
        var len = numtrials; //length (i.e. number of trials)
        var half_len = numtrials / 2;
        
        //get the basic repeated adv characteristics
        advpos_v1 = fillArray([1], half_len) // retains array of first 1's (adv 1) of length half-len 
        advpos_v2 = fillArray([2], half_len) //..and then 2's (adv 2)
        advacc_v1 = fillArray(correct_data, half_len / (correct_data.length)) //repeat all accuracy levels from the conf task
        advacc_v2 = fillArray(correct_data, half_len / (correct_data.length)) //repeat all accuracy levels from the conf task
        confadv_v1 = fillArray(confidence_data, half_len / (confidence_data.length)) //repeat all conf levels from the conf task
        confadv_v2 = shuffle(confadv_v1)//for adviser 2, shuffle all conf levels from the conf task
        advpos1 = advpos_v1.concat(advpos_v2) //concatenate them to get the correct number of trials (*2)
        advacc1 = advacc_v1.concat(advacc_v2)
        advconf = confadv_v1.concat(confadv_v2)
        
        //get for each stimpos on a trial, whether the unsigned confidence level should be in left or right direction
        advconf1 = [];
        for (var t = 0; t < len; t++) { 
            if (advacc1[t] === true && stimpos1[t] === 1) {//adviser is correct that direction is left
                advconf1.push(5 - advconf[t])//signed confidence is 5-unsigned confidence (i.e. when super certain = 4, their final confidence is 5-4=1)
            }
            else if (advacc1[t] === true && stimpos1[t] === 2) {//adviser is correct that direction is right
                advconf1.push(4 + advconf[t])//signed confidence is 4+unsigned confidence (i.e. when super certain = 4, their final confidence is 4+4=8)
            }
            else if (advacc1[t] === false && stimpos1[t] === 1) {//adviser is wrong that direction is left
                advconf1.push(4 + advconf[t])//signed confidence in rightward direction
            }
            else {
                advconf1.push(5 - advconf[t])
            }
        }
        
        //finally shuffle all these arrays horizontally, but not vertically (i.e. not to mess up the association between conf and acc)
        advpos2 = []
        advconf2 = []
        stimpos2_v2 = []
        
        for (var j = 0; j < len; j++) {//for trial j, take the j'th element in the permutation order perm, and get the associated value from the var to be shuffled
            advpos2[j] = advpos1[perm[j]]
            advconf2[j] = advconf1[perm[j]]
            stimpos2_v2[j] = stimpos1[perm[j]]
        }
        
        return advpos2
        return advconf2
        return stimpos2_v2
            
    }
};
            