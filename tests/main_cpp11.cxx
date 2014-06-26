#include <iostream>
#include <vector>

/*template <class T> void vector_concat(std::vector<T>& out) {}
template <class T, class... Rest> void vector_concat(std::vector<T>& out, T elem, Rest... rest)
{
    out.push_back(elem);
    vector_concat(out,rest...);
}
template <class T, class ContainerT, class... Rest> void vector_concat(std::vector<T>& out, const ContainerT& elems, Rest... rest)
{
    for(typename ContainerT::const_iterator iter = elems.begin(); iter != elems.end(); ++iter)
    {
        out.push_back(*iter);
    }
    vector_concat(out,rest...);
}*/

int main()
{
    std::vector<int> a(5,1);
    std::vector<int> b(5,2);
    std::vector<int> c(5,3);
    //vector_concat(c,b,a);
    for(std::vector<int>::iterator i = c.begin(); i != c.end(); ++i)
    {
        std::cout << *i << std::endl;
    }
}
