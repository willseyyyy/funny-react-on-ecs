import React, { useEffect, useState } from 'react'

export default function App() {
  const [deployedAt, setDeployedAt] = useState('loading...')

  useEffect(() => {
    // silly animation tick for vibes
    const d = new Date().toLocaleString()
    setDeployedAt(d)
  }, [])

  return (
    <main style={{ 
      minHeight: '100vh', 
      display: 'grid', 
      placeItems: 'center', 
      fontFamily: 'ui-sans-serif, system-ui, Segoe UI, Roboto, Helvetica',
      background: 'linear-gradient(120deg, #e0f7ff, #fff0f7)'
    }}>
      <div style={{ 
        background: 'white', 
        padding: '2rem 2.5rem', 
        borderRadius: '1.5rem',
        boxShadow: '0 20px 40px rgba(0,0,0,0.08)',
        maxWidth: 720
      }}>
        <h1 style={{ fontSize: '2.2rem', margin: 0 }}>🚀 Hello from ECS (maybe)!</h1>
        <p style={{ fontSize: '1.1rem', lineHeight: 1.5 }}>
          This tiny React app was built by Jenkins, baked into a Docker image, 
          pushed to ECR, and deployed to AWS. If you can read this,
          congrats—you just did DevOps. Your coffee is now ☕ officially “infrastructure”.
        </p>
        <hr />
        <p><b>Deployed at:</b> {deployedAt}</p>
        <p style={{ opacity: 0.8 }}>
          Tip: push a new commit and watch your pipeline flex.
          (It deploys faster than your roommate finishes Maggi.)
        </p>
        <button 
          onClick={() => alert('Ship it! ✨')}
          style={{ 
            padding: '0.8rem 1.2rem', 
            borderRadius: '999px', 
            border: 'none',
            background: '#111827',
            color: 'white',
            fontWeight: 600,
            cursor: 'pointer'
          }}
        >
          Re-deploy vibes
        </button>
      </div>
    </main>
  )
}
