function [trainIds,testIds] = split_data(sen_ids,selected_ids,seed)    
    rng(seed);
    sentences = unique(sen_ids(find(selected_ids))); 
    sentences = sentences(randperm(length(sentences)));   
    split = fix(length(sentences)*0.5);
    trainSentences = sentences(1:split);
    testSentences = sentences(split+1:end);
    trainIds = ismember(sen_ids,trainSentences);
    testIds = ismember(sen_ids,testSentences);
end