<%@page import="exception.BannedUserException"%>
<%@page import="exception.AlreadyActivedReservationException"%>
<%@page import="service.UserRentService"%>
<%@page import="exception.UserRentAlreadyExists"%>
<%@page import="java.util.UUID"%>
<%@page import="java.util.Map"%>
<%@page import="service.RentService"%>
<%@page import="entity.Rent"%>
<%@page import="entity.User"%>
<%@page contentType="text/html;charset=UTF-8" language="java" %>

<%
	var sessionUser = session.getAttribute("user");
	
	if (sessionUser == null || !(sessionUser instanceof User)) {
		response.sendRedirect("sign-in.jsp");
		return;
	}
		
	User user = (User) sessionUser;
	String erro = "";
	
	if (request.getMethod().equalsIgnoreCase("post")) {
		String rentId = request.getParameter("id");
	    
	    if (rentId == null) {
	    	response.sendRedirect("rent.jsp");
	    	return;
	    }
	    
	    Rent rent = RentService.getInstance().findById(UUID.fromString(rentId));
	    
	    if (rent == null) {
	    	response.sendRedirect("rentals.jsp");
	    	return;
	    }
	    
	    try {
	    	UserRentService.getInstance().rent(rent, user);
	    	session.setAttribute("sucesso", "Espaço alugado com sucesso.");
	    	response.sendRedirect("my-rentals.jsp");
	    	return;
	    } catch(UserRentAlreadyExists | AlreadyActivedReservationException | BannedUserException e) {
	    	erro = e.getMessage();
	    }
	    
	}
	
	Map<Long, String> rentType = Map.of(1L, "Auditório", 2L, "Salão de festas");
%>

<!doctype html>
<html lang="pt-br">
	<head>
	    <meta charset="UTF-8">
	    <meta name="viewport" content="width=device-width, initial-scale=1.0">
	    <title>Alugar espaço | Natureza Viva</title>
	    <script src="https://cdn.tailwindcss.com"></script>
	    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
	</head>
	<body class="bg-gray-100 flex flex-col items-center justify-center min-h-screen pt-16">
	    <header class="fixed top-0 left-0 w-full bg-white shadow mb-6 z-10">
	        <div class="max-w-6xl mx-auto px-4 py-4 flex items-center justify-between">
	            <div class="flex items-center">
	                <i class="fas fa-leaf text-green-500 mr-2"></i>
	                <h1 class="text-xl font-bold text-green-500">Natureza Viva</h1>
	            </div>
	            <nav class="flex space-x-4">
	                <a href="my-rentals.jsp" class="font-bold text-zinc-700 hover:text-zinc-950">Alugados</a>
	                <a href="rent.jsp" class="font-bold text-zinc-700 hover:text-zinc-950">Alugar</a>
	                <a href="sign-out.jsp" class="font-bold text-rose-600 hover:text-rose-800">Sair</a>
	            </nav>
	        </div>
	    </header>
	
	    <main class="mt-16 flex-grow flex items-center justify-center w-full px-4">
		    <% if (user.actived()) { %>
		        <section class="max-w-6xl w-full h-[750px] rounded-lg overflow-y-auto" role="region" aria-labelledby="list-title">
		            <div class="grid gap-4 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-4">
		                <% for (Rent r : RentService.getInstance().findAvailableRentals()) { %>
		                    <form action="<%= request.getRequestURI() %>" method="post">
		                        <div class="bg-white rounded-lg shadow p-4 flex flex-col justify-between h-full min-h-[300px]">
		                            <div class="flex-grow h-[220px] max-h-[220px] overflow-y-auto">
		                                <h2 class="text-lg font-semibold text-gray-800"><%= r.name() %></h2>
		                                <p class="text-gray-600 mt-2"><%= r.address() + ". " + "Disponível de " + r.initialDatetime() + " à " + r.finalDatetime() + ", " + r.description() %></p>
		                                <p class="text-muted-foreground mt-1 text-sm"><%= rentType.get(r.rentType()) %></p>
		                            </div>
		                            <input type="hidden" name="id" value="<%= r.id() %>">
		                            <button class="mt-4 bg-green-500 text-white font-semibold py-2 w-full rounded hover:bg-green-600 focus:outline-none focus:ring-2 focus:ring-green-400 focus:ring-offset-2 text-center" aria-label="Alugar espaço">
		                                Alugar
		                            </button>
		                        </div>
		                    </form>
		                <% } %>
		            </div>
		        </section>
		    <% } else { %>
		        <div class="text-center text-red-600 font-semibold text-md">
		            Você está banido e não pode acessar a listagem de aluguéis.
		        </div>
		    <% } %>
		</main>
	
	    <% if (!erro.equals("")) { %>
	        <div class="fixed bottom-4 right-4 bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded shadow-lg" role="alert">
	            <span class="font-bold">Erro:</span>
	            <span class="block sm:inline"><%= erro %></span>
	        </div>
	    <% } %>
	</body>
</html>

