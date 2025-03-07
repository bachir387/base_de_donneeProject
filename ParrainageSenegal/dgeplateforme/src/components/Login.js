// src/components/Login.js
import React, { useState } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';

function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const response = await axios.post('http://localhost:8000/auth/login.php', {
        email,
        password,
      });
      const { token } = response.data;
      localStorage.setItem('token', token);
      navigate('/'); // Redirige vers la page d'accueil
    } catch (err) {
      setError('Login failed. Please check your credentials.');
    }
  };

  return (
    <div>
       <div className="container">
      <h2>DGE Member Login</h2>
      <form onSubmit={handleSubmit}>
        <div>
          <label>Email: </label>
          <input 
            type="email" 
            value={email}
            onChange={(e)=> setEmail(e.target.value)}
            required 
          />
        </div>
        <div>
          <label>Password: </label>
          <input 
            type="password" 
            value={password}
            onChange={(e)=> setPassword(e.target.value)}
            required 
          />
        </div>
        {error && <p style={{color: 'red'}}>{error}</p>}
        <button type="submit">Login</button>
      </form>
      </div>
    </div>
  );
}

export default Login;
