program EM, rclass
version 16
    _parse comma matrix rest : 0
    capture confirm matrix `matrix'
    
    if _rc != 0{
        display as error "Input should be a vector"
    }
    
    syntax anything(name=mt) [,nclass(integer 3) TOLerance(real 1e-5) niter(integer 50)]
    mata: x = st_matrix("`matrix'")
    mata: r = EM(1)
    mata: r.fit(x, `nclass', `tolerance', `niter') 

    return add

end

version 16
set matastrict on
mata:
class EM
{
    public:
        real scalar nclass
        pointer(real matrix) scalar X
        real scalar tol
        real rowvector mu_new
        real rowvector Sigma_new
        real rowvector pi_new
        real rowvector mu_0
        real rowvector Sigma_0
        real rowvector pi_0
        real matrix    gamma
        real matrix    dupl_x
        real matrix classes
        real rowvector N_k
        // Functions
        void fit()
        real scalar N()
        real matrix classnormden()
        real scalar loglikelihood()
        real matrix gammaupdate()
        real rowvector N_kupdate()
        real rowvector sigmaupdate()
        real rowvector piupdate()
        real rowvector muupdate()
        real colvector getclasses()
}
void EM::fit(real matrix user_X, real scalar user_nclass, real scalar tol, real scalar niter)
{
    real matrix classes
    real rowvector history
    real scalar converge, iter
    X = &user_X
    nclass = user_nclass
    dupl_x = J(1, nclass, *X)
    history = J(niter, 1, 0)
    converge = 0
    iter = 1
    /// Initialize
    pi_new = J(1, nclass, 1 / nclass)
    mu_new = J(1, 1, rnormal(1, nclass, 0, 1))
    Sigma_new = J(1, nclass, 1)
    while ((converge == 0) && (iter <= niter))
    {
        pi_0 = pi_new
        mu_0 = mu_new
        Sigma_0 = Sigma_new
        // M step
        gamma = gammaupdate()
        // E step
        N_k = N_kupdate()
        // Update mu
        mu_new = muupdate()
        // Update Sigma
        Sigma_new = sigmaupdate()
        // Update pi
        pi_new = piupdate()
        history[iter] = abs(loglikelihood(pi_new, mu_new, Sigma_new) - loglikelihood(pi_0, mu_0, Sigma_0))
        if(history[iter] < tol)
        {
            converge = 1
        }
        iter = iter + 1
    }
    
    classes = getclasses()
    st_rclear()
    st_matrix("r(class)", rowsum(classes))
    st_matrix("r(mu)", mu_new')
    st_matrix("r(Sigma)", Sigma_new')
    st_matrix("r(pi)", pi_new')
    st_matrix("r(history)", select(history,(history:>0)))
    st_matrix("r(X)", *X)
    st_matrix("r(gamma)", gamma)
    
}
real scalar EM::N() return(rows(*X))
real matrix EM::classnormden(real rowvector mu, real rowvector sigma)
{
    real matrix dnorm
    real scalar i
    dnorm = normalden(dupl_x, mu, sqrt(sigma))
    return(dnorm)
}
real matrix EM::gammaupdate()
{
    real matrix dnorm, pi_dnorm
    dnorm = classnormden(mu_0, Sigma_0)
    pi_dnorm = pi_0 :* dnorm
    return((pi_dnorm :/ rowsum(pi_dnorm)))
}
real rowvector EM:: N_kupdate()
{
    return(colsum(gamma))
}
real rowvector EM:: muupdate()
{
    return(colsum(gamma :* dupl_x) :/ N_k)
}
real rowvector EM:: sigmaupdate()
{
    real matrix x_mu, x_mu_sq
    x_mu   = dupl_x :- mu_new
    x_mu_sq = x_mu :* x_mu
    return(colsum(gamma :* x_mu_sq) :/ N_k)
}
real rowvector EM:: piupdate()
{
    return(N_k :/ N())
}
real scalar EM::loglikelihood(real rowvector pi, real rowvector mu, real rowvector sigma)
{
    real matrix dnorm
    dnorm = classnormden(mu, sigma)
    return(sum(ln(rowsum(pi :* dnorm))))
}
real colvector EM::getclasses()
{
    real scalar j, i, w
    classes = J(N(), 1, .)
    for(j = 1; j <= N(); j++)
    {
        maxindex(gamma[j, ], 1, i, w )
        classes[j] = i 
    }
    return(classes)
}
end