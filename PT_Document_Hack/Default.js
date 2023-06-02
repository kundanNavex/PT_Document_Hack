var success = "success";
var error = "error";

$(window).load(function () {

});

// Initialize Quesrystrig
const params = new Proxy(new URLSearchParams(window.location.search), {
	get: (searchParams, prop) => searchParams.get(prop),
});
var documentid = params.docid;

$(document).ready(function () {
	savePageData(documentid, '1')
	readTextFile("/data/pageStore.json", function (text) {
		var json = JSON.parse(text);
		//console.log(data);
		for (let i = 0; i < json.length; i++) {
			let obj = json[i];
			debugger;
			if (documentid == obj.docid) {
				viewDocument(obj.docpath, "False", undefined, undefined);
				break;
			}
		}
	});

	//viewDocument("D:\\PT_DocumentView\\PT_Document_Hack\\UserFiles\\Healthcare_Benefits_(85_2).pdf", "False", undefined, undefined);
});

function readTextFile(file, callback) {
	var rawFile = new XMLHttpRequest();
	rawFile.overrideMimeType("application/json");
	rawFile.open("GET", file, true);
	rawFile.onreadystatechange = function () {
		if (rawFile.readyState === 4 && rawFile.status == "200") {
			callback(rawFile.responseText);
		}
	}
	rawFile.send(null);
}

function viewDocument(filePath, isFolder, added, deleted) {
	resetDocumentViewerModalData();
	// If it is a folder, dont do anything, let server handle it
	if (isFolder == "True") {
		return true;
	}
	else {
		// Get file name from path
		var fileNameIndex = filePath.lastIndexOf("\\") + 1;
		var fileName = filePath.substr(fileNameIndex);
		// Show the document viewer modal dialog
		$("#DocumentViewerDialog").modal();
		// Set title
		$("#DocumentViewerDialogTitle").text(fileName);
		getDocumentData(filePath);

		// Update the summary, if available (in case of comparison)
		if (added != null && deleted != null) {
			$("#DocumentViewerSummary").removeClass("hidden");
			$("#DocumentViewerSummaryAdded").text(added);
			$("#DocumentViewerSummaryDeleted").text(deleted);
		}
		return false;
	}
}

function getDocumentData(filePath) {
	filePath = filePath.replace(/\\/g, "\\\\");
	$.ajax({
		type: "POST",
		url: "Default.aspx/GetDocumentData",
		data: '{ filePath: "' + filePath + '" , sessionID: "' + $("#txtSessionID").val() + '" }',
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		success: function (data) {
			// If there is error
			if (data.d[0].substr(0, 5) == error) {
				$("#DocumentViewerAlert").addClass("alert-danger");
				$("#DocumentViewerAlert").removeClass("hidden");
				$("#DocumentViewerAlert").text(data.d);
			}
			else {

				// In case call is successful, pass data to success method
				getDocumentData_Success(data.d);
			}
		},
		failure: function (data) {
			alert('error');
		}
	});
}

function savePageData(docid, pageNo) {
	//filePath = filePath.replace(/\\/g, "\\\\");
	debugger;
	$.ajax({
		type: "POST",
		url: "Default.aspx/SavePageData",
		data: '{ docid: "' + docid + '",pageNo: "' + pageNo + '" }',
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		success: function (data) {
			debugger;
			// If there is error
			if (data.d[0].substr(0, 5) == error) {

			}
			else {

				// In case call is successful, pass data to success method
				//getDocumentData_Success(data.d);
			}
		},
		failure: function (data) {
			alert('error');
		}
	});
}

function GetPageViewdData(docid) {
	//filePath = filePath.replace(/\\/g, "\\\\");
	debugger;
	$.ajax({
		type: "POST",
		url: "Default.aspx/GetPageViewdData",
		data: '{ docid: "' + docid + '" }',
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		success: function (data) {
			debugger;
			// If there is error
			if (data.d[0].substr(0, 5) == error) {

			}
			else {
				var StringPagesStore = data.d;
				var arrPagesStore = String(StringPagesStore).split(',');
				arrPagesStore.forEach(function (item, index) {
					//console.log(item, index);
					$("#PageLI" + item).addClass("active");
				});
				// In case call is successful, pass data to success method
				//getDocumentData_Success(data.d);
			}
		},
		failure: function (data) {
			alert('error');
		}
	});
}

function getDocumentData_Success(result) {
	var totalPages = result[1];
	var imageFolder = result[2];
	//alert(totalPages);
	// Show the first page
	$("#CurrentDocumentPage").attr("src", imageFolder + "/0.png");
	// Show pagination
	$("#DocumentViewerPagination").removeClass("hidden");
	$("#spnTotalPages").html("Document contains: " + totalPages + " pages");
	// Add pages in pagination
	for (var iPage = 1; iPage <= totalPages; iPage++) {
		var PageLI = 'PageLI' + iPage;
		var currentPage = 'setCurrentPage(&quot;' + imageFolder + '/' + (iPage - 1) + '.png' + '&quot;, ' + iPage + ',' + PageLI + ')';
		//alert(currentPage);
		$("#DocumentViewerPaginationUL li:nth-child(" + iPage + ")")
			.after('<li class="DocumentViewerPaginationLI"><a id="' + PageLI + '" onclick="' + currentPage + '" href="#">' + iPage + '</a></li>');

	}
	$("#PageLI1").addClass("active");
	arrPages.push(1);
	GetPageViewdData(documentid);
}

function resetDocumentViewerModalData() {
	// Reset the alert
	$("#DocumentViewerAlert").addClass("hidden");
	$("#DocumentViewerAlert").removeClass("alert-danger");
	$("#DocumentViewerAlert").removeClass("alert-info");
	$("#DocumentViewerAlert").removeClass("alert-success");
	$("#DocumentViewerAlert").removeClass("alert-warning");

	// Hide the pagination
	$("#DocumentViewerPagination").addClass("hidden");
	// Remove all the pagination LI items with class DocumentViewerPaginationLI
	$(".DocumentViewerPaginationLI").remove();

	// Reset the default blank image for current page
	$("#CurrentDocumentPage").attr("src", "http://localhost:50465/Temp/temp.png");

	// Hide the summary
	$("#DocumentViewerSummary").addClass("hidden");
}

function setCurrentPage(currentPage, iPage, PageLI) {
	debugger;
	$("#CurrentDocumentPage").attr("src", currentPage);
	$("#" + PageLI.id).addClass("active");
	//alert(PageLI.id);
	//alert(e.target.id);
	AddPageClick(iPage);

}

var arrPages = [];

function AddPageClick(iPage) {
	if (!arrPages.includes(iPage)) {
		arrPages.push(String(iPage));
	}
	savePageData(documentid, iPage);
}

//$(".select-document").on('click', function (event) {
//    var checkboxes = $('.select-document :checked');
//    // If more than 2 documents are selected, show error and return
//    if (checkboxes.length > 2)
//    {
//        $("#PageGeneralDialog").modal();
//        $("#PageGeneralDivAlert").removeClass("hidden");
//        $("#PageGeneralDivAlert").addClass("alert-danger");
//        $("#PageGeneralDivAlert").text("Please select only 2 documents for comparison.");
//        return false;
//    }
//});

// Compare two selected documents
function btnCompare_onClick() {
	var checkboxes = $('.select-document :checked');
	// If more than 2 documents are selected, show error and return
	if (checkboxes.length != 2) {
		$("#PageGeneralDialog").modal();
		$("#PageGeneralDivAlert").removeClass("hidden");
		$("#PageGeneralDivAlert").addClass("alert-danger");
		$("#PageGeneralDivAlert").text("Please select 2 documents for comparison.");
		return false;
	}

	var documents = new Array();
	checkboxes.each(function (index, elem) {
		var documentName = $(elem).parent().parent().parent().find(".link-document").val();
		$("#divPageAlert").append(documentName + " , ");
		documents.push(documentName);
	});

	// Replace the \ with \\, it is special character
	documents[0] = documents[0].replace(/\\/g, "\\\\");
	documents[1] = documents[1].replace(/\\/g, "\\\\");

	compareDocuments(documents[0], documents[1]);
}

// Compare two selected documents
function btnCompareURLs_onClick() {
	var documents = new Array();
	documents[0] = $("#txtFirstURL").val();
	documents[1] = $("#txtSecondURL").val();
	//alert("hello");

	compareDocuments(documents[0], documents[1]);
}

// This is generic method that will take URL of two documents for comparison (WEB or File)
function compareDocuments(document1, document2) {
	resetDocumentViewerModalData();
	// Call server side method to compare the documents
	$.ajax({
		type: "POST",
		url: "Default.aspx/CompareDocuments",
		data: '{ document1: "' + document1 + '" , document2: "' + document2 + '" }',
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		success: function (data) {
			// If there is error
			if (data.d[0].substr(0, 5) == error) {
				$("#DocumentViewerAlert").addClass("alert-danger");
				$("#DocumentViewerAlert").removeClass("hidden");
				$("#DocumentViewerAlert").text(data.d);
				$("#DocumentViewerDialog").modal();
			}
			else {

				// In case call is successful, pass data to success method
				var comparisonDocument = data.d[1];
				viewDocument(comparisonDocument, "False", data.d[2], data.d[3]);
			}
		},
		failure: function (data) {
			alert('error');
		}
	});
}