/*Here, we use the function genMixed to generate univariate data with K=5 classes and n=1000 observations. It is instructive to note that the true classes are available to us. Therefore, after EM function, we use the adjusted Rand Index (ARI) as a measure of performance for the EM algorithm (see Chapter 25 of Murphy (2013) for more details). ARI is a number between 0 and 1. The numbers closer to 1 indicates better performance. For the adjusted Rand Index estimation, we resort to ari function available form the package sadi.*/
set seed 100
matrix probs = (0.1, 0.25, 0.25, 0.2, 0.2)
matrix mns = (-1\ -0.5\  0\ 0.5\ 1)
matrix sds  = (0.05\ 0.05 \ 0.05\ 0.05\ 0.05)

genMixed ,n(1000) prob(probs) means(mns) sds(sds)

matrix y = e(y)
matrix true_class = e(classes)
EM y , nclass(5) niter(50)

matrix est_class = r(class)
matrix history   = r(history)


svmat true_class
svmat est_class
svmat history

ari  true_class1 est_class1 // install this from ssc 