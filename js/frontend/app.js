const { useState, useEffect } = React;
const e = React.createElement;

function App() {
  const [categories, setCategories] = useState([]);
  const [products, setProducts] = useState([]);
  const [categoryName, setCategoryName] = useState('');
  const [productName, setProductName] = useState('');
  const [productPrice, setProductPrice] = useState('');
  const [productCategoryId, setProductCategoryId] = useState('');
  const [cart, setCart] = useState([]);
  const [paid, setPaid] = useState(false);

  const fetchCategories = () => {
    axios.get('/api/categories').then(res => setCategories(res.data));
  };

  const fetchProducts = () => {
    axios.get('/api/products').then(res => setProducts(res.data));
  };

  useEffect(() => {
    fetchCategories();
    fetchProducts();
  }, []);

  const addCategory = () => {
    if (!categoryName) return;
    axios.post('/api/categories', { name: categoryName }).then(() => {
      setCategoryName('');
      fetchCategories();
    });
  };

  const addProduct = () => {
    if (!productName || !productPrice) return;
    axios.post('/api/products', {
      name: productName,
      price: parseFloat(productPrice),
      categoryId: productCategoryId ? parseInt(productCategoryId) : null,
    }).then(() => {
      setProductName('');
      setProductPrice('');
      setProductCategoryId('');
      fetchProducts();
    });
  };

  const addToCart = (product) => {
    setCart([...cart, product]);
  };

  const totalPrice = cart.reduce((sum, p) => sum + p.price, 0);

  const pay = () => {
    if (cart.length === 0) return;
    setCart([]);
    setPaid(true);
    setTimeout(() => setPaid(false), 3000);
  };

  return e('div', { className: 'container' },
    e('h1', null, 'Simple Store'),
    e('section', { className: 'lists' },
      e('h2', null, 'Products'),
      e('ul', null,
        products.map(p =>
          e('li', { key: p.id }, `${p.name} - ${p.price}$ `,
            e('button', { onClick: () => addToCart(p) }, 'Add to cart')
          )
        )
      ),
      e('div', null,
        e('input', {
          value: productName,
          onChange: e => setProductName(e.target.value),
          placeholder: 'Product name'
        }),
        e('input', {
          value: productPrice,
          onChange: e => setProductPrice(e.target.value),
          placeholder: 'Price',
          type: 'number'
        }),
        e('input', {
          value: productCategoryId,
          onChange: e => setProductCategoryId(e.target.value),
          placeholder: 'Category ID',
          type: 'number'
        }),
        e('button', { onClick: addProduct }, 'Add Product')
      )
    ),
    e('section', null,
      e('h2', null, 'Categories'),
      e('ul', null,
        categories.map(c => e('li', { key: c.id }, `${c.id}. ${c.name}`))
      ),
      e('div', null,
        e('input', {
          value: categoryName,
          onChange: e => setCategoryName(e.target.value),
          placeholder: 'Category name'
        }),
        e('button', { onClick: addCategory }, 'Add Category')
      )
    ),
    e('section', { className: 'cart' },
      e('h2', null, 'Cart'),
      e('ul', null,
        cart.map((p, idx) => e('li', { key: idx }, `${p.name} - ${p.price}$`))
      ),
      e('p', null, `Total: ${totalPrice}$`),
      e('button', { onClick: pay }, 'Pay'),
      paid && e('p', { className: 'paid-msg' }, 'Payment successful!')
    )
  );
}

ReactDOM.render(
  React.createElement(App),
  document.getElementById('root')
);
