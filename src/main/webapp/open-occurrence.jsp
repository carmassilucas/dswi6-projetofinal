<%@page import="exception.UserNotFoundException"%>
<%@page import="exception.OccurrenceNotFoundException"%>
<%@page import="dto.OccurrenceDetails"%>
<%@page import="exception.OccurrenceAlreadyExistsException"%>
<%@page import="dto.CreateOccurrenceRequest"%>
<%@page import="entity.Occurrence"%>
<%@page import="service.OccurrenceService"%>
<%@page import="service.UserService"%>
<%@page import="entity.UserRent"%>
<%@page import="service.UserRentService"%>
<%@page import="dto.EditRentRequest"%>
<%@page import="java.util.UUID"%>
<%@page import="java.util.Map"%>
<%@page import="entity.Rent"%>
<%@page import="exception.DateRangeException"%>
<%@page import="java.sql.SQLException"%>
<%@page import="exception.RentAreadyExists"%>
<%@page import="service.RentService"%>
<%@page import="dto.CreateRentRequest"%>
<%@page import="java.time.LocalDateTime"%>
<%@page import="entity.User"%>
<%@page contentType="text/html;charset=UTF-8" language="java" %>

<%
    var sessionUser = session.getAttribute("user");

    if (sessionUser == null || !(sessionUser instanceof User)) {
    	response.sendRedirect("sign-in.jsp");
    	return;
    }
   	
    User u = (User) sessionUser;
    
    if (u.userType() != 2L) {
    	response.sendRedirect("rent.jsp");
    	return;
    }
    
    if (!u.actived()) {
    	session.setAttribute("erro", "Usuário inativo, altere sua senha para ativar.");
    	response.sendRedirect("change-password.jsp");
    	return;
    }
    
    String rentId = request.getParameter("id");
    UserRent userRent = null;
    User user = null;
    Rent rent = null;
    
    if (rentId != null) {
    	userRent = UserRentService.getInstance().findById(Long.parseLong(rentId));
    	
    	if (userRent != null && userRent.rentStatus() != 5L) {
        	response.sendRedirect("closure.jsp");
        	session.setAttribute("erro", "Estado de reserva diferente de finalizado.");
        	return;
        }
    	
    	user = UserService.getInstance().findById(userRent.userId());
    	rent = RentService.getInstance().findById(userRent.rentId());
    }
    
    String erro = "";
    String sucesso = "";
    
    if (request.getMethod().equalsIgnoreCase("post")) {
    	String action = request.getParameter("action");
    	
    	if (action == null) {
	    	response.sendRedirect("open-occureence.jsp");
	    	return;
	    }
    	
    	try {
    		if (action.equals("create")) {
        		String description = request.getParameter("description");
        		OccurrenceService.getInstance().create(new CreateOccurrenceRequest(userRent.id(), description));
        		UserService.getInstance().ban(user.id());
        		sucesso = "Ocorrência cadastrada e usuário banido com sucesso.";
        	} else if(action.equals("unban")) {
        		Long occurrenceId = Long.parseLong(request.getParameter("occurrenceId"));
        		UUID userId = UUID.fromString(request.getParameter("userId"));
        		OccurrenceService.getInstance().unban(occurrenceId, userId);
        		sucesso = "Usuário desbanido com sucesso";
        	}
    	} catch(OccurrenceAlreadyExistsException | OccurrenceNotFoundException | UserNotFoundException e) {
    		response.sendRedirect("open-occurrence.jsp");
    		session.setAttribute("erro", e.getMessage());
    		return;
    	}
    	
	}    
    
    Map<Long, String> rentType = Map.of(1L, "Auditório", 2L, "Salão de festas");
    
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
	    <title>Abrir ocorrência | Natureza Viva</title>
	    <script src="https://cdn.tailwindcss.com"></script>
	    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
	</head>
	<body class="bg-gray-100 flex flex-col items-center justify-center min-h-screen">
	    <header class="fixed top-0 left-0 w-full bg-white shadow mb-6 z-10">
	        <div class="max-w-6xl mx-auto px-4 py-4 flex items-center justify-between">
	            <div class="flex items-center">
	                <i class="fas fa-leaf text-green-500 mr-2"></i>
	                <h1 class="text-xl font-bold text-green-500">Natureza Viva</h1>
	            </div>
	            <nav class="flex space-x-4">
	                <a href="rentals.jsp" class="font-bold text-zinc-700 hover:text-zinc-950">Espaços</a>
	                <a href="closure.jsp" class="font-bold text-zinc-700 hover:text-zinc-950">Fechamento</a>
	                <a href="open-occurrence.jsp" class="font-bold text-zinc-700 hover:text-zinc-950">Ocorrências</a>
	                <a href="sign-out.jsp" class="font-bold text-rose-600 hover:text-rose-800">Sair</a>
	            </nav>
	        </div>
	    </header>
	
		<% if (rent == null) { %>
			<main class="mt-16 flex-grow flex items-center justify-center w-full px-4">
			    <section class="max-w-6xl w-full h-[750px] rounded-lg overflow-y-auto" role="region" aria-labelledby="list-title">
			        <div class="grid gap-4 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-4">
			            <% for (OccurrenceDetails occurrence : OccurrenceService.getInstance().findAll()) { %>
			                <form action="<%= request.getRequestURI() %>" method="post" class="bg-white rounded-lg shadow p-4 flex flex-col justify-between h-full min-h-[300px]">
			                    <div class="max-h-[180px] overflow-y-auto">
				                    <h2 class="text-lg font-semibold text-gray-800"><%= occurrence.rentName() %></h2>
				                    <p class="text-gray-600 mt-2"><span class="font-semibold"><%= occurrence.userName() %></span> banido por: <%= occurrence.occurrence().description() %></p>
				                </div>
			                    
			                    <input type="hidden" name="occurrenceId" value="<%= occurrence.occurrence().id() %>">
			                    <input type="hidden" name="userId" value="<%= occurrence.userId() %>">
			                    
			                    <div class="mt-4 text-center">
				                    <% if (occurrence.occurrence().unblockUser()) { %>
				                        <span class="text-green-500 font-semibold" aria-label="Usuário desbanido">
				                            Usuário desbanido
				                        </span>
				                    <% } else { %>
				                        <button name="action" value="unban" type="submit" class="w-full bg-red-500 hover:bg-red-600 text-white font-bold py-2 px-4 rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500" aria-label="Desbanir usuário">
								            Desbanir
								        </button>
				                    <% } %>
				                </div>
			                </form>
			            <% } %>
			        </div>
			    </section>
			</main>
		<% } else { %>
			<main class="mt-16 flex-grow flex items-center justify-center w-full px-4">
		        <div class="max-w-6xl w-full grid grid-cols-1 md:grid-cols-10 gap-6">
		            <form action="<%= request.getRequestURI() %>?id=<%= userRent.id() %>" method="post" class="max-h-[550px] bg-white p-6 rounded-lg shadow-md space-y-4 md:col-span-3" role="form" aria-labelledby="form-title">
		                <h3 id="form-title" class="text-xl font-bold text-center text-rose-500 mb-4">Criar ocorrência</h3>
		                
		                <div class="max-h-[220px] overflow-y-auto">		                
		                	<span class="my-2 text-sm text-gray-500 font-semibold">Espaço reservado por <%= user.name() %>. <%= rent.address() + ". " + "Disponível de " + rent.initialDatetime() + " à " + rent.finalDatetime() + ", " + rent.description() %></span>
		                </div>

		                <div class="mb-4">
			                <label for="description" class="block font-medium text-gray-700">Descreva a ocorrência</label>
			                <textarea id="description" name="description" class="mt-2 h-32 max-h-32 w-full p-2 border border-gray-300 rounded-lg" placeholder="Detalhe o ocorrido..." required aria-label="Descrição da ocorrência"></textarea>
			            </div>

			            <div class="flex gap-4">
					        <a href="closure.jsp" class="w-full bg-gray-500 hover:bg-gray-600 text-white text-center font-bold py-2 px-4 rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-muted-foreground" aria-label="Cancelar">
					            Cancelar
					        </a>
					        <button name="action" value="create" type="submit" class="w-full bg-red-500 hover:bg-red-600 text-white font-bold py-2 px-4 rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500" aria-label="Cadastrar ocorrência">
					            Cadastrar
					        </button>
					    </div>
					</form>

		            <section class="space-y-4 md:col-span-7 h-[750px] rounded-lg overflow-y-auto" role="region" aria-labelledby="list-title">
					    <div class="grid gap-4 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-2 xl:grid-cols-3">
					        <% for (OccurrenceDetails occurrence : OccurrenceService.getInstance().findAll()) { %>
					            <div class="bg-white rounded-lg shadow p-4 flex flex-col justify-between h-full">
					                <div class="max-h-[180px] overflow-y-auto">
					                    <h2 class="text-lg font-semibold text-gray-800"><%= occurrence.rentName() %></h2>
					                    <p class="text-gray-600 mt-2"><%= occurrence.userName() %> banido por: <%= occurrence.occurrence().description() %></p>
					                </div>
					                <div class="mt-4 text-center">
					                    <% if (occurrence.occurrence().unblockUser()) { %>
					                        <span class="text-green-500 font-semibold" aria-label="Usuário desbanido">
					                            Usuário desbanido
					                        </span>
					                    <% } else { %>
					                        <span class="text-rose-500 font-semibold" aria-label="Usuário banido">
					                            Usuário banido
					                        </span>
					                    <% } %>
					                </div>
					            </div>
					        <% } %>
					    </div>
					</section>
		        </div>
		    </main>
		<% }
		
        if (!sucesso.equals("")) { %>
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



