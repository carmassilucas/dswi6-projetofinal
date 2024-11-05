<%@page import="java.time.LocalDateTime"%>
<%@page import="java.util.UUID"%>
<%@page import="entity.User"%>
<%@page import="service.UserService"%>
<%@page import="javax.swing.text.DateFormatter"%>
<%@page import="java.time.LocalDate"%>
<%@page contentType="text/html;charset=UTF-8" language="java" %>

<%
	String erro = "";
   	
	if (request.getMethod().equalsIgnoreCase("post")) {
		String name = request.getParameter("name");
		String username = request.getParameter("username");
		String password = request.getParameter("password");
		LocalDate birthDate = LocalDate.parse(request.getParameter("birth_date"));
		var now = LocalDateTime.now();
		
		try {
			UserService.getInstance().create(new User(
					UUID.randomUUID(), name, username, password, 1L, birthDate, now, now, false
			));
			session.setAttribute("sucesso", "Usuário cadastrado com sucesso!");
			response.sendRedirect("sign-in.jsp");
		} catch(RuntimeException e) {
			erro = e.getMessage();
		}
   	}
%>

<!doctype html>
<html lang="pt-br">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Cadastrar-se | Natureza Viva</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    </head>
    <body class="bg-gray-100 flex flex-col items-center justify-center min-h-screen">
    	<header class="fixed top-0 left-0 w-full bg-white shadow mb-6 z-10">
	        <div class="max-w-6xl mx-auto px-4 py-4 flex items-center">
	            <i class="fas fa-leaf text-green-500 mr-2"></i>
	            <h1 class="text-xl font-bold text-green-500">Natureza Viva</h1>
	        </div>
	    </header>
    
        <div class="bg-white p-6 rounded-lg shadow-md w-full max-w-md">	    
            <h1 class="text-2xl mb-6 text-center">Crie sua conta</h1>

            <form action="<%= request.getRequestURI() %>" method="post">
                <div class="mb-4">
                    <label for="name" class="block text-gray-700 mb-2">Nome</label>
                    <input type="text" name="name" id="name" class="w-full p-3 border border-gray-300 rounded-lg" placeholder="Digite seu nome" required>
                </div>

                <div class="mb-4">
                    <label for="username" class="block text-gray-700 mb-2">Nome de usuário</label>
                    <input type="text" name="username" id="username" class="w-full p-3 border border-gray-300 rounded-lg" placeholder="Digite seu nome de usuário" required>
                </div>

                <div class="mb-4">
                    <label for="password" class="block text-gray-700 mb-2">Senha</label>
                    <input type="password" name="password" id="password" class="w-full p-3 border border-gray-300 rounded-lg" placeholder="Crie uma senha" required>
                </div>

                <div class="mb-4">
                    <label for="birth_date" class="block text-gray-700 mb-2">Data de Nascimento</label>
                    <input type="date" name="birth_date" id="birth_date" class="w-full p-3 border border-gray-300 rounded-lg" required>
                </div>

                <button type="submit" class="w-full bg-blue-500 text-white py-3 rounded-lg hover:bg-blue-600 transition-colors">Cadastrar</button>
            </form>

            <p class="mt-4 text-gray-600 text-center">Já tem uma conta? <a href="sign-in.jsp" class="text-blue-500 hover:underline">Entre</a></p>
        </div>
        
        <% if (!erro.equals("")) { %>
	    	<div class="fixed bottom-4 right-4 bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded shadow-lg" role="alert">
			    <strong class="font-bold">Erro:</strong>
			    <span class="block sm:inline"><%= erro %></span>
			</div>
	    <% } %>
    </body>
</html>
