<%@page import="dto.AuthUserRequest"%>
<%@page import="exception.AuthFailedException"%>
<%@page import="entity.User"%>
<%@page import="service.UserService"%>
<%@page contentType="text/html;charset=UTF-8" language="java" %>

<%
	String erro = "";
	String sucesso = "";

	if (request.getMethod().equalsIgnoreCase("post")) {
		String username = request.getParameter("username");
		String password = request.getParameter("password");
		
		try {
			var user = UserService.getInstance().auth(new AuthUserRequest(username, password));
			session.setAttribute("user", user);
			
			if (user.userType().equals(2L)) {
				response.sendRedirect("rentals.jsp");
				return;
			}
			
			response.sendRedirect("my-rentals.jsp");
		} catch(AuthFailedException e) {
			erro = e.getMessage();
		}
	}
	
	if (session.getAttribute("sucesso") != null) {
    	sucesso = session.getAttribute("sucesso").toString();
    	session.removeAttribute("sucesso");
    }
    
    if (session.getAttribute("erro") != null) {
    	erro = session.getAttribute("erro").toString();
    	session.removeAttribute("erro");
    }
%>

<!doctype html>
<html lang="pt-br">
	<head>
	    <meta charset="UTF-8">
	    <meta name="viewport" content="width=device-width, initial-scale=1.0">
	    <title>Entrar | Natureza Viva</title>
	    <script src="https://cdn.tailwindcss.com"></script>
	    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
	</head>
	<body class="bg-gray-100 flex flex-col items-center justify-center min-h-screen pt-16">
	    <header class="fixed top-0 left-0 w-full bg-white shadow mb-6 z-10">
	        <div class="max-w-6xl mx-auto px-4 py-4 flex items-center">
	            <i class="fas fa-leaf text-green-500 mr-2"></i>
	            <h1 class="text-xl font-bold text-green-500">Natureza Viva</h1>
	        </div>
	    </header>
	
	    <div class="bg-white p-6 rounded-lg shadow-md w-full max-w-md">	    
	        <h2 class="text-2xl mb-6 text-center">Acessar Natureza Viva</h2>
	
	        <form action="<%= request.getRequestURI() %>" method="post">
	            <div class="mb-4">
	                <label for="username" class="block text-gray-700 mb-2">Nome de usuário</label>
	                <input type="text" name="username" id="username" class="w-full p-3 border border-gray-300 rounded-lg" placeholder="Digite seu nome de usuário" required>
	            </div>
	            
	            <div class="mb-6">
	                <label for="password" class="block text-gray-700 mb-2">Senha</label>
	                <input type="password" name="password" id="password" class="w-full p-3 border border-gray-300 rounded-lg" placeholder="Digite sua senha" required>
	            </div>
	            
	            <button type="submit" class="w-full bg-blue-500 text-white py-3 rounded-lg hover:bg-blue-600 transition-colors">Entrar</button>
	        </form>
	
	        <p class="mt-4 text-gray-600 text-center">Não tem uma conta? <a href="sign-up.jsp" class="text-blue-500 hover:underline">Cadastre-se</a></p>
	    </div>
	    
	    <% if (!sucesso.equals("")) { %>
	        <div class="fixed bottom-4 right-4 bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded shadow-lg" role="alert">
	            <strong class="font-bold">Sucesso:</strong>
	            <span class="block sm:inline"><%= sucesso %></span>
	        </div>
	    <% } else if (!erro.equals("")) { %>
	        <div class="fixed bottom-4 right-4 bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded shadow-lg" role="alert">
	            <strong class="font-bold">Erro:</strong>
	            <span class="block sm:inline"><%= erro %></span>
	        </div>
	    <% } %>
	</body>
</html>

