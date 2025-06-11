const { useState, useEffect } = React;

function App() {
  const [categories, setCategories] = useState([]);
  const [products, setProducts] = useState([]);
  const [categoryName, setCategoryName] = useState('');
  const [productName, setProductName] = useState('');
  const [productPrice, setProductPrice] = useState('');
  const [productCategoryId, setProductCategoryId] = useState('');

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
    axios
      .post('/api/products', {
        name: productName,
        price: parseFloat(productPrice),
        categoryId: productCategoryId ? parseInt(productCategoryId) : null,
      })
      .then(() => {
        setProductName('');
        setProductPrice('');
        setProductCategoryId('');
        fetchProducts();
      });
  };

  return React.createElement(
    'div',
    null,
    React.createElement('h2', null, 'Categories'),
    React.createElement(
      'ul',
      null,
      categories.map((c) =>
        React.createElement('li', { key: c.id }, `${c.id}. ${c.name}`)
      )
    ),
    React.createElement('input', {
      value: categoryName,
      onChange: (e) => setCategoryName(e.target.value),
      placeholder: 'Category name',
    }),
    React.createElement(
      'button',
      { onClick: addCategory },
      'Add Category'
    ),
    React.createElement('h2', null, 'Products'),
    React.createElement(
      'ul',
      null,
      products.map((p) =>
        React.createElement(
          'li',
          { key: p.id },
          `${p.id}. ${p.name} (${p.price}$) category: ${p.categoryId}`
        )
      )
    ),
    React.createElement('input', {
      value: productName,
      onChange: (e) => setProductName(e.target.value),
      placeholder: 'Product name',
    }),
    React.createElement('input', {
      value: productPrice,
      onChange: (e) => setProductPrice(e.target.value),
      placeholder: 'Price',
      type: 'number',
    }),
    React.createElement('input', {
      value: productCategoryId,
      onChange: (e) => setProductCategoryId(e.target.value),
      placeholder: 'Category ID',
      type: 'number',
    }),
    React.createElement(
      'button',
      { onClick: addProduct },
      'Add Product'
    )
  );
}

ReactDOM.render(
  React.createElement(App, null, null),
  document.getElementById('root')
);
