### TODO complete ###
function initialiseMessages()
    # Messages from leaf node factors are initialised to the factor.
    
    # Messages from leaf variable nodes are set to unity.
end

function runSP(graph, root, prior, factors, varTensor,)
    values = step1(graph,root, prior, factors, varTensor)
    result = step2(values, graph,root, prior, factors, varTensor)
    return result
end

function getLeaves(graph, rootNode)
    
end

function getFactors(graph, leafNode)
    
end


function varToFactorMess(graph, prior, fromVar, toFactor)
    
end

function facToVariableMess(graph, prior, fromFac, toVariable)
    
end
